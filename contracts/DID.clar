;; Title: Enhanced Reputation-Based Decentralized Identity System
;; Version: 2.0.0
;; Description: Advanced implementation with enhanced scoring and privacy features

;; Constants and Error Codes
(define-constant contract-owner tx-sender)
(define-constant minimum-score u300)
(define-constant maximum-score u850)
(define-constant score-increment u10)
(define-constant score-decrement u5)

(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-score (err u103))
(define-constant err-invalid-params (err u104))

;; Data Structures
(define-map UserScores
    { user: principal }
    {
        credit-score: uint,
        last-updated: uint,
        transaction-count: uint,
        verification-status: bool,
        privacy-level: uint  ;; New: Privacy control (0: Public, 1: Limited, 2: Private)
    }
)

(define-map UserTransactions
    { user: principal }
    {
        successful-txs: uint,
        failed-txs: uint,
        total-volume: uint,
        avg-transaction-size: uint,
        last-transaction-time: uint
    }
)

;; New: Access Control for Business Integration
(define-map AuthorizedBusinesses
    { business: principal }
    { 
        access-level: uint,  ;; 0: Basic, 1: Detailed, 2: Full
        verification-status: bool
    }
)

;; Enhanced Scoring Algorithm Functions
(define-private (calculate-transaction-score (user-stats {successful-txs: uint, failed-txs: uint, total-volume: uint, avg-transaction-size: uint, last-transaction-time: uint}))
    (let
        (
            (success-ratio (if (> (+ (get successful-txs user-stats) (get failed-txs user-stats)) u0)
                (/ (* (get successful-txs user-stats) u100) (+ (get successful-txs user-stats) (get failed-txs user-stats)))
                u0))
            (volume-score (/ (get total-volume user-stats) u10000))
            (recency-score (if (> (- block-height (get last-transaction-time user-stats)) u1440)  ;; 24 hours in blocks
                u0
                u50))
        )
        (+ (+ success-ratio volume-score) recency-score)
    )
)

;; Helper functions for min/max operations
(define-private (get-min (a uint) (b uint))
    (if (<= a b) a b))

(define-private (get-max (a uint) (b uint))
    (if (>= a b) a b))

(define-private (update-credit-score (user principal) (transaction-score uint))
    (match (map-get? UserScores {user: user})
        score-data
        (let
            (
                (new-score (get-min maximum-score 
                    (get-max minimum-score 
                        (+ (get credit-score score-data) transaction-score))))
            )
            (map-set UserScores
                {user: user}
                {
                    credit-score: new-score,
                    last-updated: block-height,
                    transaction-count: (+ (get transaction-count score-data) u1),
                    verification-status: (get verification-status score-data),
                    privacy-level: (get privacy-level score-data)
                }
            )
        )
        false
    )
)

;; Public Functions
(define-public (initialize-user (privacy-level uint))
    (let
        (
            (caller tx-sender)
        )
        (asserts! (<= privacy-level u2) err-invalid-params)
        (ok (map-set UserScores
            { user: caller }
            {
                credit-score: u500,
                last-updated: block-height,
                transaction-count: u0,
                verification-status: false,
                privacy-level: privacy-level
            }
        ))
    )
)

(define-public (update-transaction-history (success bool) (volume uint))
    (let
        (
            (caller tx-sender)
            (current-stats (default-to
                {
                    successful-txs: u0,
                    failed-txs: u0,
                    total-volume: u0,
                    avg-transaction-size: u0,
                    last-transaction-time: u0
                }
                (map-get? UserTransactions { user: caller })
            ))
        )
        (let
            (
                (new-total-tx (+ (get successful-txs current-stats) (get failed-txs current-stats) u1))
                (new-avg-size (/ (+ (* (get avg-transaction-size current-stats) (- new-total-tx u1)) volume) new-total-tx))
            )
            (map-set UserTransactions
                { user: caller }
                {
                    successful-txs: (if success
                        (+ (get successful-txs current-stats) u1)
                        (get successful-txs current-stats)
                    ),
                    failed-txs: (if (not success)
                        (+ (get failed-txs current-stats) u1)
                        (get failed-txs current-stats)
                    ),
                    total-volume: (+ (get total-volume current-stats) volume),
                    avg-transaction-size: new-avg-size,
                    last-transaction-time: block-height
                }
            )
        )
        (ok (update-credit-score caller (calculate-transaction-score current-stats)))
    )
)

;; Privacy-Aware Read Functions
(define-read-only (get-credit-score (user principal) (requester principal))
    (match (map-get? UserScores {user: user})
        score-data
        (let
            (
                (privacy-level (get privacy-level score-data))
                (requester-access (default-to 
                    { access-level: u0, verification-status: false }
                    (map-get? AuthorizedBusinesses {business: requester})))
            )
            (if (or 
                (is-eq user requester)
                (and (>= (get access-level requester-access) privacy-level)
                     (get verification-status requester-access)))
                (ok (get credit-score score-data))
                err-unauthorized
            )
        )
        err-not-found
    )
)

;; Business Integration Functions
(define-public (register-business (access-level uint))
    (begin
        (asserts! (<= access-level u2) err-invalid-params)
        (ok (map-set AuthorizedBusinesses
            { business: tx-sender }
            {
                access-level: access-level,
                verification-status: false
            }
        ))
    )
)

(define-public (verify-business (business principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (match (map-get? AuthorizedBusinesses {business: business})
            business-data
            (ok (map-set AuthorizedBusinesses
                { business: business }
                {
                    access-level: (get access-level business-data),
                    verification-status: true
                }
            ))
            err-not-found
        )
    )
)

;; User Privacy Control
(define-public (update-privacy-level (new-level uint))
    (begin
        (asserts! (<= new-level u2) err-invalid-params)
        (match (map-get? UserScores {user: tx-sender})
            score-data
            (ok (map-set UserScores
                { user: tx-sender }
                {
                    credit-score: (get credit-score score-data),
                    last-updated: (get last-updated score-data),
                    transaction-count: (get transaction-count score-data),
                    verification-status: (get verification-status score-data),
                    privacy-level: new-level
                }
            ))
            err-not-found
        )
    )
)