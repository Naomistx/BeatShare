;; BeatShare - Decentralized Music Royalty Distribution
;; A smart contract for transparent and automated music royalty payments

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-EXISTS (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INVALID-PERCENTAGE (err u103))
(define-constant ERR-INSUFFICIENT-FUNDS (err u104))
(define-constant ERR-INVALID-AMOUNT (err u105))

;; Data variables
(define-data-var contract-owner principal tx-sender)

;; Data maps
(define-map Songs
  { song-id: uint }
  {
    title: (string-ascii 100),
    artist: principal,
    total-royalties: uint,
    created-at: uint
  }
)

(define-map Collaborators
  { song-id: uint, collaborator: principal }
  { percentage: uint }
)

(define-map SongCounter
  principal
  uint
)

;; Private functions
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

(define-private (validate-percentage (percentage uint))
  (<= percentage u100)
)

;; Public functions

;; Register a new song with royalty splits
(define-public (register-song (title (string-ascii 100)) (collaborators (list 10 { collaborator: principal, percentage: uint })))
  (let
    (
      (song-counter (default-to u0 (map-get? SongCounter tx-sender)))
      (new-song-id (+ song-counter u1))
      (total-percentage (fold + (map get-percentage collaborators) u0))
    )
    (asserts! (<= total-percentage u100) ERR-INVALID-PERCENTAGE)
    (asserts! (> (len title) u0) ERR-INVALID-AMOUNT)
    
    ;; Store song details
    (map-set Songs
      { song-id: new-song-id }
      {
        title: title,
        artist: tx-sender,
        total-royalties: u0,
        created-at: stacks-block-height
      }
    )
    
    ;; Store collaborator splits
    (fold store-collaborator-for-song collaborators new-song-id)
    
    ;; Update song counter
    (map-set SongCounter tx-sender new-song-id)
    
    (ok new-song-id)
  )
)

;; Helper function to get percentage from collaborator tuple
(define-private (get-percentage (collaborator { collaborator: principal, percentage: uint }))
  (get percentage collaborator)
)

;; Helper function to store each collaborator for a song
(define-private (store-collaborator-for-song (collaborator { collaborator: principal, percentage: uint }) (song-id uint))
  (begin
    (map-set Collaborators
      { song-id: song-id, collaborator: (get collaborator collaborator) }
      { percentage: (get percentage collaborator) }
    )
    song-id
  )
)

;; Distribute royalties for a song
(define-public (distribute-royalties (song-id uint))
  (let
    (
      (song-data (unwrap! (map-get? Songs { song-id: song-id }) ERR-NOT-FOUND))
      (artist (get artist song-data))
    )
    (asserts! (is-eq tx-sender artist) ERR-NOT-AUTHORIZED)
    (asserts! (> (stx-get-balance tx-sender) u0) ERR-INSUFFICIENT-FUNDS)
    
    ;; Update total royalties
    (map-set Songs
      { song-id: song-id }
      (merge song-data { total-royalties: (+ (get total-royalties song-data) (stx-get-balance tx-sender)) })
    )
    
    (ok true)
  )
)

;; Get song details
(define-read-only (get-song (song-id uint))
  (map-get? Songs { song-id: song-id })
)

;; Get collaborator percentage for a song
(define-read-only (get-collaborator-split (song-id uint) (collaborator principal))
  (map-get? Collaborators { song-id: song-id, collaborator: collaborator })
)

;; Get total songs by artist
(define-read-only (get-artist-song-count (artist principal))
  (default-to u0 (map-get? SongCounter artist))
)