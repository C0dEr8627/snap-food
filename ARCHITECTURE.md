# Snap Foodd — Technical Architecture

## V1 system boundary

Consumer + Delivery Partner Flutter (mobile) ----\
Consumer + Delivery Partner Flutter (web) ------- HTTPS/JSON ---> Laravel/PHP API ---> MySQL
Admin Flutter Web (browser) ---------------------/

There are three client surfaces and one trusted backend:
1. mobile_app/ is the consumer + delivery-partner Flutter client, deployed to mobile and later Web.
2. admin_web/ is the separate Flutter Web admin client.
3. backend/ is the shared Laravel/PHP API and the **only component permitted to access MySQL**.

## V1 hosting

GoDaddy cPanel is the planned V1 hosting environment for the Laravel/PHP API and both Flutter Web applications. The exact cPanel capabilities must be verified before deployment.

## Core principles

1. Laravel is authoritative for data, workflows and business rules.
2. All Flutter applications are API clients, never database clients.
3. MySQL credentials exist only in the Laravel server environment.
4. Server-side authorization is the security boundary.
5. Controllers validate/delegate/serialize; Laravel services implement business operations.
6. Transactions protect checkout and delivery assignment.
7. No client may open a MySQL connection.
8. Architecture, API, schema, hosting and workflow changes update docs/tests.

## Client architecture

Flutter Widget/Screen -> Riverpod Controller/ViewModel -> Repository -> API Client -> HTTPS -> Laravel

## API and authentication

All APIs use /api/v1. Flutter clients use HTTPS/JSON and the documented contract. Clients cannot self-elevate roles. Browser/mobile bundles must not contain database credentials or server secrets.

## Business authority

Laravel owns product price, availability, delivery fee, order total, payment state, order status, delivery assignment and completion. MySQL is accessed only by Laravel.

## V1 deployment sequence

1. Deploy Laravel/PHP API on GoDaddy cPanel.
2. Point mobile API configuration at the production HTTPS API and verify auth/catalogue/orders/delivery/tracking.
3. Deploy admin_web Flutter Web to cPanel and verify API/CORS/auth/admin workflows.
4. Prepare and deploy consumer + delivery-partner Flutter Web.
5. Run cross-client end-to-end and security verification.
