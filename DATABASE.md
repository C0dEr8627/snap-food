# Snap Foodd — MySQL Data Model

MySQL is authoritative; Laravel migrations are the schema source of truth.

## Initial tables
- `users`: Google subject, profile, role, active state.
- `addresses`: user, label, recipient/address fields, coordinates.
- `categories`: name, slug, image/reference, ordering, active state.
- `products`: category, name, slug, description, price, image, availability/stock, active state.
- `orders`: customer, delivery-address snapshot, subtotal, delivery fee, total, payment method/status, order status.
- `order_items`: product reference plus product-name/unit-price snapshots, quantity and line total.
- `order_status_history`: order, from/to status, actor and timestamp.
- `delivery_partners`: user, approval and availability state.
- `delivery_assignments`: order, partner, status and lifecycle timestamps.
- `delivery_locations`: assignment, latitude, longitude, accuracy and recorded timestamp.
- `invoices`: order, invoice number, financial snapshots, issue time and file reference.

## Integrity
Use foreign keys/indexes, transactions for checkout/assignment, decimal-safe money and consistent timestamps. Historical order/invoice values must not depend on mutable products. Define location retention before long-term history.
