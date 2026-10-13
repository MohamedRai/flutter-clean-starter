---
name: add-api-endpoint
description: Integrate a new backend endpoint end-to-end — remote data source method, model, repository method, use case and tests. Use when the user gives an API route, a curl/Postman request or a JSON payload to support (e.g. "call GET /users/{id}/orders", "POST /orders").
---

# Add an API endpoint

Work from the data layer up. Every step has a test.

## 1. Understand the contract

Get the method, path, query/body, success JSON and error responses. If a
Postman collection or curl is provided, use it (the Postman CLI is
available). Note which fields are nullable.

## 2. Model

New payload shape → `mason make model --feature <f> --name <entity>` (entity
+ freezed model + test), then edit fields. Existing model → add fields to
both the model and the entity. Use `@JsonKey(name: 'snake_name')` when the
API is snake_case. Run `dart run build_runner build`.

## 3. Remote data source

Add the method to the abstract data source and its impl, using the
`BaseRemoteDataSource` verbs (`get<T>`, `post<T>`, `put<T>`, `patch<T>`,
`delete<T>`). Paths are relative to the flavor's `API_BASE_URL`. Decode
with `Model.fromJson`. Don't catch errors here — `safeCall` maps them.

If the backend wraps payloads (e.g. `{"data": ...}`) override `unwrap`
once in a shared subclass instead of unwrapping per call. If it uses its
own error codes, extend `HttpExceptionMapper` (see docs/networking.md).

Test: mock `Dio` with mocktail; cover success, a decoded failure
(e.g. 404 → `NotFoundException`) and a network error.

## 4. Repository

Add the method to the contract (domain) and implementation (data). Pick a
`FetchPolicy` (reads) or use `safeWrite` with `invalidateKeys` (writes).
Map models to entities with `toEntity()`. Test success + failure mapping.

## 5. Use case + presentation

Use the `add-usecase` skill (`mason make usecase ...`), then call the use
case from the relevant bloc/cubit.

## 6. Verify

```sh
dart run build_runner build
dart format lib test
flutter analyze
flutter test
```
