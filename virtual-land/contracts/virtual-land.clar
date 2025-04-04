(define-data-var owner principal tx-sender)
(define-map land-owners { land-id: uint } { owner: principal, for-sale: bool, price: uint })

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
  (if (is-eq tx-sender (var-get owner))
      (begin
        (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: true, price: price })
        (ok true))
      (err u101))) ;; unauthorized

;; Function to buy land
(define-public (buy-land (land-id uint))
  (let ((land (map-get? land-owners { land-id: land-id })))
    (match land
      land-data
        (if (and (get for-sale land-data)
                 (>= (stx-get-balance tx-sender) (get price land-data)))
            (begin
              ;; transfer ownership logic (omitting token transfer logic for brevity)
              (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: false, price: (get price land-data) })
              (ok true))
            (err u102)) ;; not for sale or insufficient funds
      (err u103)))) ;; land not found

;; Function to list land for sale
(define-public (list-land (land-id uint) (price uint))
  (let ((land (map-get? land-owners { land-id: land-id })))
    (match land
      land-data
        (if (is-eq tx-sender (get owner land-data))
            (begin
              (map-set land-owners { land-id: land-id } { owner: tx-sender, for-sale: true, price: price })
              (ok true))
            (err u104)) ;; unauthorized
      (err u105)))) ;; land not found
