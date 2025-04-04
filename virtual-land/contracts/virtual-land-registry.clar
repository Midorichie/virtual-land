;; Virtual Land Registry Contract
;; A smart contract for managing metadata about virtual land parcels
 
;; Data Maps
(define-map land-metadata
  { land-id: uint }
  {
    name: (string-ascii 50),
    description: (string-ascii 256),
    coordinates: { x: int, y: int },
    features: (list 10 (string-ascii 50))
  }
)

;; Check if metadata exists
(define-read-only (has-metadata (land-id uint))
  (is-some (map-get? land-metadata { land-id: land-id })))
 
;; Register metadata for a land parcel
(define-public (register-metadata
                (land-id uint)
                (name (string-ascii 50))
                (description (string-ascii 256))
                (x int)
                (y int)
                (features (list 10 (string-ascii 50))))
  (begin
    ;; Verify the user owns the land
    (let ((is-owner (contract-call? .virtual-land is-land-owner land-id tx-sender)))
      (asserts! is-owner (err u201)) ;; Not the land owner
      
      ;; Check that metadata doesn't already exist
      (asserts! (not (has-metadata land-id)) (err u203)) ;; Metadata already exists
      
      ;; Validate coordinates (optional, adjust range as needed)
      (asserts! (and (>= x (- 1000)) (<= x 1000)) (err u204)) ;; X coordinate out of range
      (asserts! (and (>= y (- 1000)) (<= y 1000)) (err u205)) ;; Y coordinate out of range
      
      ;; Set the metadata
      (map-set land-metadata
               { land-id: land-id }
               {
                 name: name,
                 description: description,
                 coordinates: { x: x, y: y },
                 features: features
               })
      (ok true))))
 
;; Get metadata for a land parcel
(define-read-only (get-metadata (land-id uint))
  (map-get? land-metadata { land-id: land-id }))
 
;; Update metadata for a land parcel (only owner can update)
(define-public (update-metadata
                (land-id uint)
                (name (string-ascii 50))
                (description (string-ascii 256))
                (x int)
                (y int)
                (features (list 10 (string-ascii 50))))
  (begin
    ;; Verify the user owns the land
    (let ((is-owner (contract-call? .virtual-land is-land-owner land-id tx-sender)))
      (asserts! is-owner (err u201)) ;; Not the land owner
      
      ;; Check that metadata exists
      (asserts! (has-metadata land-id) (err u202)) ;; Metadata doesn't exist
      
      ;; Validate coordinates (optional, adjust range as needed)
      (asserts! (and (>= x (- 1000)) (<= x 1000)) (err u204)) ;; X coordinate out of range
      (asserts! (and (>= y (- 1000)) (<= y 1000)) (err u205)) ;; Y coordinate out of range
      
      ;; Update the metadata
      (map-set land-metadata
               { land-id: land-id }
               {
                 name: name,
                 description: description,
                 coordinates: { x: x, y: y },
                 features: features
               })
      (ok true))))
