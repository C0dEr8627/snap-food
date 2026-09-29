# Snap Foodd

Snap Foodd is a Flutter food-delivery application backed by Laravel/PHP and MySQL.

## Release scope
- **Customer mobile:** Google SSO, catalogue/search, cart, COD checkout, orders and active delivery tracking.
- **Delivery Partner mobile:** approved-partner sign-in, delivery requests, pickup/delivery workflow and active-trip GPS.
- **Admin web:** products, categories, orders, delivery partners, assignments and invoices.
- **Restaurant Partner:** deferred for this release.

## Approved technical decisions

| Area | Decision |
|---|---|
| Mobile | Flutter / Dart |
| State + DI | Riverpod 3 |
| Navigation | go_router |
| Backend | Laravel / PHP |
| API | REST under `/api/v1` |
| Database | MySQL |
| Auth | Google OAuth SSO |
| OTP | Deferred |
| Payments | COD |
| Maps | Google Maps Platform |
| Tracking | Active-trip HTTP updates + polling |
| Admin | Separate Laravel web dashboard |
| Hosting | GoDaddy; exact plan must be verified |
| Backend style | Laravel modular monolith |
| WebSockets | Not required for MVP |

## Documentation source of truth
Read before coding:
1. [PRODUCT.md](PRODUCT.md)
2. [ARCHITECTURE.md](ARCHITECTURE.md)
3. [API_CONTRACT.md](API_CONTRACT.md)
4. [DATABASE.md](DATABASE.md)
5. [AUTH.md](AUTH.md)
6. [DELIVERY_TRACKING.md](DELIVERY_TRACKING.md)
7. [ADMIN.md](ADMIN.md)
8. [DEVELOPMENT.md](DEVELOPMENT.md)
9. [AI_RULES.md](AI_RULES.md)
10. [DESIGN.md](DESIGN.md)
11. [DEVELOPER_1_PLAN.md](DEVELOPER_1_PLAN.md) — Laravel/API/MySQL/Admin task plan
12. [DEVELOPER_2_PLAN.md](DEVELOPER_2_PLAN.md) — Flutter/Maps task plan
13. [AIDLC_WORKFLOW.md](AIDLC_WORKFLOW.md) — parallel AI workflow, branches, commits and PRs
14. [AI_TASK_BOARD.md](AI_TASK_BOARD.md) — shared integration milestones
15. [AI_TASK_TEMPLATE.md](AI_TASK_TEMPLATE.md) — reusable scoped task definition
16. [`.github/pull_request_template.md`](.github/pull_request_template.md) — required PR checklist

If code and documentation disagree, update them together.

## Engineering rules
- Backend is authoritative for business rules and data.
- Flutter widgets do not own API calls, persistence, pricing or workflow decisions.
- Never trust client role, price, availability, total, payment state or order status.
- Keep repository boundaries between features and external data sources.
- Keep secrets out of Flutter and Git.
- Preserve existing UI unless a design change is explicitly requested.
- Loading, empty, error and degraded-network states are part of completion.
- Update docs/tests when architecture, API, schema or workflow changes.

## Implementation order
1. Verify GoDaddy capabilities.
2. Laravel + MySQL foundation.
3. Google SSO end-to-end.
4. Catalogue/admin.
5. Cart + COD checkout.
6. Admin order/delivery assignment.
7. Delivery partner workflow.
8. Maps + active tracking.
9. Invoices.
10. Security/integration/device release testing.

See [DEVELOPMENT.md](DEVELOPMENT.md) for sequencing, [AIDLC_WORKFLOW.md](AIDLC_WORKFLOW.md) for the required AI development lifecycle, and [AI_TASK_BOARD.md](AI_TASK_BOARD.md) for shared milestone tracking.
