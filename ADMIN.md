# Snap Foodd — Admin Web Dashboard

Admin is a separate Laravel web dashboard, not a hidden role in the customer Flutter app.

## MVP
- **Dashboard:** basic new/active/preparing/awaiting-delivery/active-delivery counts.
- **Catalogue:** category/product CRUD, price and availability, supported images.
- **Orders:** search/filter, detail, status, COD state, delivery assignment and invoices.
- **Delivery partners:** provision/approve, activate/deactivate, availability, active assignment and basic history.

Admin actions require Laravel web authentication and authorization. UI visibility is not security. Prioritize clear tables, search/filter, fast actions, confirmations and explicit loading/error/empty states.
