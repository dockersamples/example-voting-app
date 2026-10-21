# Organisation Merchant: Registration/Login vs Self-Service Split

This change separates organisation-merchant functionality in **Payloft.Onboarding** across two controllers:

- **Registration and login** is served by `OrganizationMerchantService` through `OrganisationController`.
- **Self-service** is served by `OrgMerchantService` through the new `OrganisationSelfServiceController`.

No service code was changed. The work is limited to controller wiring and DI registration.

The full background, the permission model, the flow walkthroughs and the proposed fixes for known issues are in [`ORG_MERCHANT_SPLIT_TECHNICAL.md`](./ORG_MERCHANT_SPLIT_TECHNICAL.md).

---

## What changed

```
Gateway.Core/
└── Services/
    └── Organization/
        ├── OrganizationMerchantService.cs          unchanged
        └── OrgMerchantService.cs                   unchanged

Payloft.Onboarding/
├── Program.cs                                      edited  (+2 DI registrations)
└── Controllers/
    ├── OrganisationController.cs                   edited  (regrouped + merchant login endpoint)
    └── OrganisationSelfServiceController.cs        new
```

| File | Change |
|---|---|
| `Program.cs` | Registers `OrganizationMerchantService` and `OrgMerchantService` in DI. Neither was registered before. |
| `OrganisationController.cs` | Moves the four merchant-registration endpoints into their own region. Adds `POST organisation-merchant-login`. Nothing else changed. |
| `OrganisationSelfServiceController.cs` | New controller exposing the 12 public methods of `OrgMerchantService` one-to-one. |

## Setup

Add these lines to `Payloft.Onboarding/Program.cs`, next to `builder.Services.AddScoped<OrganizationService>();`:

```csharp
builder.Services.AddScoped<Gateway.Core.Services.Organization.OrganizationMerchantService>();
builder.Services.AddScoped<OrgMerchantService>();
```

Without the first line, `OrganisationController` cannot be constructed, and every endpoint on it fails at request time.

## Endpoints

### `api/Organisation` (registration and login)

| Method | Route | Auth | Service call |
|---|---|---|---|
| GET | `merchant-registration-link` | JWT | `GenerateMerchantRegistrationLink` |
| POST | `organisation-merchant-register-email` | Anonymous | `RegisterEmail(model)` |
| POST | `organisation-merchant-registration/{organisationId}/{token}` | Anonymous | `RegisterEmail(model, orgId, token)` |
| POST | `organisation-merchant-register` | JWT (see known issues) | `Register` |
| POST | `organisation-merchant-login` **(new)** | Anonymous | `OrgMerchantLogin` |

### `api/OrganisationSelfService` (self-service)

| Method | Route | Gate | Service call |
|---|---|---|---|
| GET | `merchants` | `org:merchants:view` | `GetMerchantsAsync` |
| GET | `merchants/{id}` | `org:merchants:view` | `GetMerchant` |
| GET | `merchants/{merchantId}/detail` | authenticated | `GetMerchantDetail` |
| GET | `business` | authenticated | `GetBusiness` |
| POST | `merchants/{merchantId}/business` | `Update Business` | `UpdateBusiness` |
| POST | `merchants/{id}/edit-request` | `org:merchants:onboard` | `EditMerchant` |
| GET | `edit-requests` | `org:merchants:approve` | `GetMerchantAuthorizationRequest` |
| POST | `edit-requests/{id}/decision` | `org:merchants:approve` | `ApproveOrDeclineMerchantRequest` |
| POST | `merchants/{id}/reset-encryption-key` | `org:security:manage` | `ResetEncryptionKeyAsync` |
| POST | `go-live` | authenticated | `RequestForGoLiveAsync` |
| GET | `onboarding/{onboardingId}` | authenticated | `GetOnboardingAsync` |
| POST | `onboarding/sla` (multipart form) | `Upload Document` | `UploadSlaDoc` |

The `org:*` gates are checked against the database via `OrganizationService.HasPermissionAsync`. Merchant-scope gates use `[RequirePermission]` against the token's `Permissions` claim.

## Who calls what

- **Org staff** log in via `POST api/Organisation/login` and use the merchant directory, edit, approval and key-reset endpoints.
- **Merchant users** log in via `POST api/Organisation/organisation-merchant-login` and use the business, go-live, onboarding and SLA endpoints.

## Known issues (not fixed in this change)

These are documented, with root cause and proposed fixes, in the technical document.

| # | Severity | Issue |
|---|---|---|
| 1 | Critical | `OrgMerchantLogin` resolves the default org for anonymous requests, so merchants in real orgs cannot log in. |
| 2 | Critical | `MerchantController.ResetEncryptionKeyAsync` is `[AllowAnonymous]` and returns the new key and IV. |
| 3 | Critical | `users/switch-to-org-admin` has no permission check. |
| 4 | High | `get-organization-transaction` has `[AllowAnonymous]`, which bypasses `[RequirePermission]`. |
| 5 | High | A merchant user can act on sibling merchants in the same org (`UpdateBusiness`, `GetOnboarding`, `UploadSlaDoc`). |
| 6 | High | `organisation-merchant-register` requires a JWT that the user cannot have yet. |
| 7 | Medium | Maker and checker can be the same person on merchant edit requests. |
| 8 | Medium | "Domain-based" signup lands every user in the default org. |
| 9 | Medium | `CreateRole` permission check is commented out; `merchant-registration-link` is ungated. |
| 10 | Low | Duplicate permission `live:keys:rotate` (ids 28 and 1029); `Permissions.cs` is out of sync with the DB. |

## Quick verification

1. The app starts, and `GET api/Organisation/roles` with an org-admin token returns 200. This confirms DI resolves.
2. An org admin calling `GET api/OrganisationSelfService/merchants` gets their org's merchants only.
3. A merchant-user token calling the same endpoint gets 403.
4. `POST api/Organisation/organisation-merchant-login` succeeds for a default-org merchant. It is expected to fail for a real-org merchant until issue 1 is fixed.
