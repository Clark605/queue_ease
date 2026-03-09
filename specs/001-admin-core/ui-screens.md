# UI Screens: Admin Core (Sprint 2)

**Stitch Project**: QueueEase  
**Project ID**: `10237896241607667264`  
**Device**: Mobile 390px (rendered at 780px wide, 2× density)  
**Theme**: Inter font, `#136dec` primary, light mode, 8px border-radius  
**Last Updated**: 2026-02-28

This document maps every Stitch screen to its corresponding Flutter page / widget and implementation step in [quickstart.md](quickstart.md).

---

## Admin Screens — Sprint 2 (001-admin-core)

### 1. Business Admin Dashboard

| Field | Value |
|---|---|
| **Stitch Screen ID** | `8dfd84da8a4e47bfb11d83662b881e0c` |
| **Screenshot** | ![Business Admin Dashboard](https://lh3.googleusercontent.com/aida/AOfcidUvB9qvG6Tn2teDz6yqtIBCbHpAw3ZjQrsaX4XUTxdTV3dh_8cK1ztWwfidmxe8sBN2tL8lhSaqlMLu6CsjmWNBFA7Gx-FXoIl1IFJ-yBl3OBnhFFLEvPml8tFHXjj1ebxZvXbk1ti4sLjVsmXMNNJRFiwrzfIcYjBaiGAZxlPVBqDYAUmBsAizGOmzssV6k2n_wtDgFsvVjx0xtktHxR6ZpUn9GvblH3l0fH3_3eSc9gJhY6qo-Yy7jxta) |
| **Flutter page** | existing `lib/admin/dashboard/presentation/pages/admin_dashboard_page.dart` |
| **Route** | `/a/dashboard` |
| **Quickstart step** | Step 10 |
| **Notes** | Entry point after setup; wraps content with TutorialCubit overlay. Bottom nav links to Org Profile and Services. |

---

### 2. Organization Landing Screen (Variant 3)

| Field | Value |
|---|---|
| **Stitch Screen ID** | `2561164f987a4e7c84c9c59d56576da7` |
| **Screenshot** | ![Organization Landing Screen Variant 3](https://lh3.googleusercontent.com/aida/AOfcidXfYecYdZQPQT48C2xxS5KWF638tSJm4wl7TUhfuUNzfWwTdxEkTZ1UkQKsly5IysJXdiZo3leCK9PRDlxr3ErixHtjvkxjQYg5IxZx5W0d5iB9SiuVoJEDF3DpIf-6319d7W4_Yk2xJfpsK6b6eCiQmNnHYAS_fOKOpKR5o0VgdUnRjdlmB5LxTA1oQHROpxV8UzL6oIhO9mhu_DFvE0zvXiR6gPLgg2s68NiTK9YLCq6Ezva2QCQJi9sT) |
| **Flutter page** | `lib/admin/organization/presentation/pages/organization_profile_page.dart` |
| **Route** | `/a/org/profile` |
| **Quickstart step** | Step 7 |
| **Notes** | Displays org name, address, description, slug. Hero header area + info cards. FAB / edit button → `/a/org/edit`. Also doubles as design reference for `organization_setup_page.dart` (stripped-down single-field variant). |

---

### 3. Services Management — Empty State

| Field | Value |
|---|---|
| **Stitch Screen ID** | `6390660a070a4727baea580118dd6bca` |
| **Screenshot** | ![Services Management Empty State](https://lh3.googleusercontent.com/aida/AOfcidX7fSG89WrM_nOPQSNUmJ59i1OJ3GcJGO737bc4cQWVmaBfTC4Iq-Tz-hDTDF8uyVSW7qlImNA8H2Qi2YT51k2CtjV9MEaMerqpfoM2QyrRrHk4gouZ1YxBn90JxlEYaXOUn8reiJ_ZAY4_zV_V4wcjPN-W7V736lqC9QGB8MO5o2q5aVZWo19x_hQbJKwHZ6EW3hLnBpGFbrgFDDj2JKQMVAYTp4lJNEZeMb6XFwNo7kWMUflazgFkLWx8) |
| **Flutter page** | `lib/admin/services/presentation/pages/service_list_page.dart` |
| **Route** | `/a/services` |
| **Quickstart step** | Step 8 |
| **Notes** | Empty-state illustration + CTA text + FAB. Render when `ServiceLoaded(services: [])`. |

---

### 4. Services Management — List

| Field | Value |
|---|---|
| **Stitch Screen ID** | `eb2781a9ff3646ef87decaf682022a32` |
| **Screenshot** | ![Services Management List](https://lh3.googleusercontent.com/aida/AOfcidWgv6ISJy6zJEbEMFW9HmeKwncDGev3ijgHGepHTcKNZseH3ysGj7otdP8R5cF87xRoQc752Jr82ZMTUSrC1gDhqTHJFAvB29DwnyygIswu1ypBihZQoExZrXlwN6zkoB6jNqtnJm5UezJzOuXXQG6L0zdWYUfTWRdJLsC8vtAXTT3A0QD_oUjMoaboePLqmXX59tnvgfCb4sgiwPx0R5iEOjDKOJdc-vyXqh4eA-6KzWSt4DgkgoJcLBUK) |
| **Flutter page** | `lib/admin/services/presentation/pages/service_list_page.dart` |
| **Route** | `/a/services` |
| **Quickstart step** | Step 8 |
| **Notes** | Card-based list. Each `service_list_tile.dart` shows name, duration, active/inactive badge, edit + delete icons. FAB adds new service. |

---

### 5. Add Service Form (Variant 2)

| Field | Value |
|---|---|
| **Stitch Screen ID** | `eb5dc21cc1624d30877ae249112e941a` |
| **Screenshot** | ![Add Service Form Variant 2](https://lh3.googleusercontent.com/aida/AOfcidVtspga87UYozmgfW8iE6Yrrttw5tluA_EXjrge7l2qv9qkjN8QYAnFZrWUdIuxaK9JsA-dS7iiFNoil2HGGFWNMrZEUSMVtNFufzb1J86MrMa44SEK98zvYKDqJkripuVjQbBzILIkYatJ5oRcjFKihHvhcOtfhY0JdCLGeU9_XL9CfE9TinlU_jxcZSxFAhkDsMivrVSHMVhDC5WlyJdw0zEYc3Km6xHr_EoPUfz1L36QHneK4VvPAIT-) |
| **Flutter page** | `lib/admin/services/presentation/pages/service_form_page.dart` |
| **Route** | `/a/services/form` |
| **Quickstart step** | Step 8 |
| **Notes** | Fields: service name, duration (minutes), time margin, description, active toggle. Title "Add Service" when `service == null`. Primary action button at bottom. |

---

### 6. Edit Service Form (Variant 1)

| Field | Value |
|---|---|
| **Stitch Screen ID** | `dd7e56c4ee974bc2a41b13443f8b0b75` |
| **Screenshot** | ![Edit Service Form Variant 1](https://lh3.googleusercontent.com/aida/AOfcidWwxjbDdXkka_AlltD9CvTyQ7zlK4EZUJHDL-5uFnpKNmHo47irrcQ1Dw_lL5gB4-TJDO2FYNrUw75eXZrwhLGaBiCEU_EBvesEBrVli_o2AYM1NGu5olIZZsqITZX09xcQoOA5Qw-fh_ZxNrLYUTCGF1nR8i0GlVFA0CFilb9xJcqn-DgKHHSfHnWikATt0oe8IKTKk0ewtLgcwWV4V8sMieL82-MwBfdUMKbWqsnSZzBZLcjTdjoYilLZ) |
| **Flutter page** | `lib/admin/services/presentation/pages/service_form_page.dart` |
| **Route** | `/a/services/form?mode=edit` |
| **Quickstart step** | Step 8 |
| **Notes** | Same page as Add Service; title changes to "Edit Service"; fields pre-populated from `ServiceEntity`. Includes delete option in app bar overflow. |

---

### 7. Service Details — Modern Grid

| Field | Value |
|---|---|
| **Stitch Screen ID** | `2dc2ab8c7eab425497cafcb23034f587` |
| **Screenshot** | ![Service Details Modern Grid](https://lh3.googleusercontent.com/aida/AOfcidX2jdhZa88AQhKd5iyt-ccxAMRWCPb-QQPPKPU5tNLY-URpGpZZl2Es_lejNfeYwK8EX94GpxXFxq1o9GP-uVUi412zXQPhDe-Qlys93lfpFNVrN3PdAMF8AVe2DyH1YBdeomHku2JEazL054cqLUEGl-QpBo5mna6hydHGq0vrAFn2IG7mtdVB-GD0kBmGxcLgf5-BhgQLsx15R-VU2AiA5YSl7Udwwaef9581HnuPuExznIxvW423hms0) |
| **Flutter page** | Use as reference for `organization_profile_page.dart` detail card layout |
| **Route** | N/A (layout reference) |
| **Quickstart step** | Step 7 |
| **Notes** | Grid card layout with stat chips. Can inform how org profile page presents key metrics (slug, services count). Also useful for any future "service detail" deep-dive page. |

---

## Admin Screens — Future Sprints

### Share Access & QR Code

| Field | Value |
|---|---|
| **Stitch Screen ID** | `69a07f9f77464dbea8c2c3c0d8c422ee` |
| **Screenshot** | ![Share Access QR Code](https://lh3.googleusercontent.com/aida/AOfcidWJzVyJ_64u45v89i3ai8bdk7kK4QTqnqJ-FI-8gf5a2WCj3KSUzpwu0shYO7J514GYrUtqpj-hecABAY2OL5UYr2NIkD9xcxkLpZ4AaHXsGqE8PxCUgU5j2Y2tbJBucMIdDD7mBJurnNzxb6V5g8tjjRQf_DGwCw1QMLCd4SIgZAQDAxqhM2UqUtuXJcU_nu_D6lAZl_bmc93O86X_1FhZnKTHHc9Zz03W3FBMjFr7tBNQm0pa79sjMTDe) |
| **Flutter page** | `lib/admin/share_access/` (skeleton exists) |
| **Sprint** | Sprint 2 scope TBD / Sprint 3 |

---

### Live Queue Management

| Field | Value |
|---|---|
| **Stitch Screen ID** | `934cca359e9243518864a9575d55e860` |
| **Screenshot** | ![Live Queue Management](https://lh3.googleusercontent.com/aida/AOfcidUDyj1igOqqc75XVlgHd1ZIOeFrcCYgHhImjhNLS3Gduyz31GXWhl1e8KZepiFsZdgUSPf5F1x539Zvji3a2TVnN_OXwtqfkk-urLzDA792oFb2UX8Ir6D2oHPa4AnHJrjmS6m_mtWKGHAQ6Kozk5ohjMtp0rMY3XtIdPq8xr0ACNLbUWe9zikAIhW63UbrC_7KDQGMF_NsDptZFFMKxz3B9Xbc8dsTdM0KwtRDHJLeSTaOjzTFhyIf1vTn) |
| **Flutter page** | `lib/admin/queue_management/` (skeleton exists) |
| **Sprint** | Sprint 3 |

---

### Working Hours Configuration

| Field | Value |
|---|---|
| **Stitch Screen ID** | `30a66cbc56df4c09a3d8a997c8a0aa6c` |
| **Screenshot** | ![Working Hours Configuration](https://lh3.googleusercontent.com/aida/AOfcidUSG_LmaiP1pzaTDfdx0Qw9MwQhdNYe-S6gGVoLoRhl2RGasU0Ruybnup6kmef9sXCidyaJARs6Wrc5-vg0eKXI_nI1Vu6ElBRmfHlQBfu-U7V2dzhiWYXMpvNqunWrT1VodtSaZjOytadCHDo0Z-ciYqroKOQfm7mH2_Pz3-0eYxg_gLOXFuYsladiazibaVM0meaDVj0fD3wiPY6MwXpIAIJDD6LJSdQUApWEnW3WE59bI) |
| **Flutter page** | `lib/admin/working_hours/` (skeleton exists) |
| **Sprint** | Sprint 3 |

---

### Access Portal Variant 2

| Field | Value |
|---|---|
| **Stitch Screen ID** | `4068bef5185e4af6a0e0eae5aec270eb` |
| **Screenshot** | ![Access Portal Variant 2](https://lh3.googleusercontent.com/aida/AOfcidXYu_Ru5iz6jTyOOzexEveOg3dNENl5oV2GLtYY_3yHBb8f8ajczlRxq3ZpWks1yH4Fbq2xB5iYFF1FNsutAJ2NseKKpgB3BRlJyC7scrsjYWnN0pocn_nOIbP7M1XHYuzo2acFw2i1m8v4U59bxFF4fZJh_foFO_55I30Xeh5vMfyU1evRp5kDxCqu9fDwye0iz5sSAzz3hHpSHQYMCxqke0yVvkgA4LzUam5UPRijOXU5c6hDPpNwAG8F) |
| **Flutter page** | Customer-facing org entry page (likely `lib/customer/`) |
| **Sprint** | Sprint 3 |

---

## Customer Screens (not Sprint 2 admin scope)

| Title | Screen ID | Flutter Module |
|---|---|---|
| Onboarding: Skip the Wait | `51b1b1ae36a841dbb5732a55009bcb03` | Customer onboarding slides |
| Onboarding: Fair Turns | `d524f65768f54aa38acb9393838b61e0` | Customer onboarding slides |
| Onboarding: Real-Time Tracking | `a410645fb52f47f9be3c7434fb6433e9` | Customer onboarding slides |
| Select Service | `274e634b73234d1880893156e54e18c7` | `lib/customer/` booking flow |
| Select Time Slot | `f72661d1da2d4912a64ee0eaa80cf23b` | `lib/customer/` booking flow |
| Queue Status: Waiting | `4662fc96e41c4cc0a11af127a8bf646f` | `lib/customer/` queue status |
| Queue Status: Almost Turn | `127e2043e3f5455b9b6d67ef166cff7b` | `lib/customer/` queue status |
| Queue Status: Serving | `27e7ffff2a9843bcb7d314ffb2077ea1` | `lib/customer/` queue status |
| Queue Status: Missed | `dea3fb9cf3ac458f9c09f2dbe7f00468` | `lib/customer/` queue status |
| Customer Dashboard | `8698c11066f94d8a8f4b8b037c40322b` | `lib/customer/` dashboard |
| Customer Dashboard (alt) | `ec3ebbf17c0443e39de6efa3d1df4594` | `lib/customer/` dashboard |
| QueueEase Splash Screen | `21e9394307234d92b624982a6f008ca5` | `lib/core/` splash |

---

## Auth Screens (Sprint 1 — complete)

| Title | Screen ID | Status |
|---|---|---|
| Login and Sign Up | `0a32902032ca4897b5209861d07b3e09` | ✅ Implemented Sprint 1 |

---

## Gaps / Missing Screens

The following admin screens specified in the spec have **no corresponding Stitch design** yet:

| Spec Screen | FR | Notes |
|---|---|---|
| Organization Setup ("Complete Your Setup") | FR-005 | No dedicated Stitch screen. Use the Organization Landing Screen (Variant 3) as reference with a simplified single-field layout. |
| Admin Tutorial Overlay | FR-019–022 | No tutorial overlay screen in Stitch. Design a 3-step overlay widget using the app's primary colour (`#136dec`) and the existing Onboarding slides as visual tone reference. |
| Organization Profile Edit | FR-006, FR-007 | No dedicated edit screen. Derive from "Organization Landing Screen Variant 3" layout, replacing read-only fields with `TextFormField` inputs. |

---

## How to View Screens in Stitch

Open any screen in the browser by constructing the URL:  
`https://stitch.withgoogle.com/project/10237896241607667264`

Or reference the screenshot URL directly from the `downloadUrl` fields in the Stitch API response for each screen.
