;; Virtual Land Contract - Phase 2
;; A smart contract for managing ownership and transactions of virtual land parcels

;; Data Variables
(define-data-var owner principal tx-sender)
(define-data-var contract-paused bool false)
(define-data-var currently-in-call bool false)

;; Data Maps
(define-map land-owners { land-id: uint } { owner: principal, for-sale: bool, price: uint })
(define-map rental-agreements 
  { land-id: uint } 
  { 
    tenant: principal, 
    expiry: uint, 
    price-paid: uint 
  }
)

;; Private Functions
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get owner)))

(define-private (validate-price (price uint))
  (> price u0))

;; Check if land exists
(define-private (land-exists (land-id uint))
  (is-some (map-get? land-owners { land-id: land-id })))

;; Initialize contract (only the contract deployer can run this)
(define-public (initialize)
  (begin
    (if (is-eq (var-get owner) tx-sender)
        (err u100) ;; already initialized
        (begin
          (var-set owner tx-sender)
          (ok true)))))

;; Function to mint new virtual land - only owner can mint
(define-public (mint-land (land-id uint) (price uint))
  (begin
    ;; Check contract pause status
    (asserts! (not (var-get contract-paused)) (err u111)) ;; contract paused
    ;; Validate inputs
    (asserts! (validate-price price) (err u113)) ;; invalid price
    ;; Check if land already exists
    (asserts! (not (land-exists land-id)) (err u115)) ;; land already exists
    
    (if (is-eq tx-sender (var-get owner))
        (begin
          (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: true, price: price })
          (ok true))
        (err u101)))) ;; unauthorized

;; Function to buy land - fixed to include token transfer
(define-public (buy-land (land-id uint))
  (begin
    ;; Check contract pause status
    (asserts! (not (var-get contract-paused)) (err u111)) ;; contract paused
    ;; Implement non-reentrancy guard
    (asserts! (not (var-get currently-in-call)) (err u112)) ;; reentrancy detected
    ;; Check if land exists
    (asserts! (land-exists land-id) (err u103)) ;; land not found
    
    (var-set currently-in-call true)
    
    (let ((land (unwrap! (map-get? land-owners { land-id: land-id }) (begin
                                                                       (var-set currently-in-call false)
                                                                       (err u103)))))
      (if (and (get for-sale land)
              (>= (stx-get-balance tx-sender) (get price land)))
          (begin
            ;; Transfer STX from buyer to seller
            (try! (stx-transfer? (get price land) tx-sender (get owner land)))
            ;; Update ownership
            (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: false, price: (get price land) })
            ;; Reset reentrancy guard
            (var-set currently-in-call false)
            (ok true))
          (begin
            ;; Reset reentrancy guard
            (var-set currently-in-call false)
            (err u102)))))) ;; not for sale or insufficient funds

;; Function to list land for sale
(define-public (list-land (land-id uint) (price uint))
  (begin
    ;; Check contract pause status
    (asserts! (not (var-get contract-paused)) (err u111)) ;; contract paused
    ;; Validate inputs
    (asserts! (validate-price price) (err u113)) ;; invalid price
    ;; Check if land exists
    (asserts! (land-exists land-id) (err u103)) ;; land not found
    
    (let ((land (unwrap! (map-get? land-owners { land-id: land-id }) (err u103))))
      (if (is-eq tx-sender (get owner land))
          (begin
            (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: true, price: price })
            (ok true))
          (err u104))))) ;; unauthorized

;; Check if a user owns a specific land parcel
(define-read-only (is-land-owner (land-id uint) (user principal))
  (let ((land (map-get? land-owners { land-id: land-id })))
    (match land
      land-data (is-eq (get owner land-data) user)
      false)))

;; Rent land to another user
(define-public (rent-land (land-id uint) (tenant principal) (duration uint) (price uint))
  (begin
    ;; Check contract pause status
    (asserts! (not (var-get contract-paused)) (err u111)) ;; contract paused
    ;; Validate inputs
    (asserts! (validate-price price) (err u113)) ;; invalid price
    (asserts! (> duration u0) (err u114)) ;; invalid duration
    ;; Check if land exists
    (asserts! (land-exists land-id) (err u103)) ;; land not found
    
    (let ((land (unwrap! (map-get? land-owners { land-id: land-id }) (err u103))))
      (if (is-eq tx-sender (get owner land))
          (begin
            ;; Create rental agreement
            (map-set rental-agreements 
                    { land-id: land-id } 
                    { tenant: tenant, expiry: (+ block-height duration), price-paid: price })
            (ok true))
          (err u106))))) ;; not the owner

;; Accept a rental agreement and transfer payment
(define-public (accept-rental (land-id uint))
  (begin
    ;; Check contract pause status
    (asserts! (not (var-get contract-paused)) (err u111)) ;; contract paused
    ;; Implement non-reentrancy guard
    (asserts! (not (var-get currently-in-call)) (err u112)) ;; reentrancy detected
    ;; Check if land exists
    (asserts! (land-exists land-id) (err u103)) ;; land not found
    
    (var-set currently-in-call true)
    
    (let ((rental (unwrap! (map-get? rental-agreements { land-id: land-id }) 
                          (begin
                            (var-set currently-in-call false)
                            (err u108))))
          (land (unwrap! (map-get? land-owners { land-id: land-id })
                         (begin
                           (var-set currently-in-call false)
                           (err u103)))))
      (if (and (is-eq tx-sender (get tenant rental))
               (< block-height (get expiry rental)))
          (begin
            ;; Transfer payment from tenant to owner
            (try! (stx-transfer? (get price-paid rental) tx-sender (get owner land)))
            (var-set currently-in-call false)
            (ok true))
          (begin
            ;; Reset reentrancy guard
            (var-set currently-in-call false)
            (err u107)))))) ;; not the tenant or rental expired

;; Check for adjacent land ownership (bonus features)
(define-read-only (owns-adjacent-lands (land-id uint) (user principal))
  (let ((adjacent-1 (+ land-id u1))
        (adjacent-2 (- land-id u1)))
    (and (is-land-owner land-id user)
         (or (is-land-owner adjacent-1 user)
             (is-land-owner adjacent-2 user)))))

;; Emergency pause function
(define-public (pause-contract)
  (begin
    (asserts! (is-contract-owner) (err u110)) ;; not authorized
    (var-set contract-paused true)
    (ok true)))

;; Resume contract operations
(define-public (resume-contract)
  (begin
    (asserts! (is-contract-owner) (err u110)) ;; not authorized
    (var-set contract-paused false)
    (ok true)))

;; Get contract status
(define-read-only (get-contract-status)
  (var-get contract-paused))

;; Get owner of specific land
(define-read-only (get-land-owner (land-id uint))
  (let ((land (map-get? land-owners { land-id: land-id })))
    (match land
      land-data (ok (get owner land-data))
      (err u103))))  ;; land not found

;; Get rental agreement details
(define-read-only (get-rental-details (land-id uint))
  (map-get? rental-agreements { land-id: land-id }))
