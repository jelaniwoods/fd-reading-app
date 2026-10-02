# Application guidance

Work on this repository as ordinary application source. You may edit every file, replace a starter choice when
needed, and add features with conventional Rails or established gems. No further Compile is required.
Read `.firstdraft/design/implementation-notes.md` and `.firstdraft/gaps.json` if retained for product decisions,
open questions, and reviewed support gaps. This context is removable and is not required to run or test the app.

[README.md](README.md) owns setup, commands, preview, and database continuation. For screens or interactions, use
the [UI task index](UI.md#task-index) to select the relevant sections. Read [DEPLOY.md](DEPLOY.md) before deployment.
Inspect existing code before adding a parallel stack. Keep the README's product description and operating
instructions accurate as behavior changes.

When asked to review First Draft updates, use the public
[First Draft changelog](https://github.com/firstdraft/skills/blob/main/CHANGELOG.md).
Optional `.firstdraft/updates.md` records the last reviewed entry; reviewed does not mean adopted.
That reading checkpoint is not a runtime dependency.

- Put ERB copy through `t()` in `config/locales/`; missing translations raise in development/test and erb_lint
  checks literal ERB text. Review Ruby/JavaScript copy too.
- Preserve Rails authorization, CSRF, validation, and non-JavaScript form/navigation fallbacks when enhancing UI.
  Inspect related screens in a real browser, at narrow and desktop widths and in each supported palette.
- System specs audit accessibility. Keep the layout's `data-turbo-not-loaded`, application.js submit/load markers,
  and `WaitForTurboBeforeClick` together so Turbo redirects finish before clicks and audits.
- Preserve the native layout marker and `hotwire_native_app?` presentation: the client owns navigation and its
  WebView supplies color preference. Browser user-agent checks do not prove actual native-client behavior.
- Render persistent messages into the existing `#flash_notices` / `#flash_alerts` live regions. UI.md explains
  form-card flash placement and transient success messages.
- Paginate collections with Pagy. Ordinary lazy association reads are allowed; preload useful associations and
  use Bullet plus query-growth specs for important collections. Do not render unbounded relations.
- Follow strong_migrations instructions (`safe_by_default` is on). Put justified schema-check exceptions under
  the specific detector in `.active_record_doctor.rb`.
- Bulk writes bypass validations and callbacks. Their writer owns recomputing derived/counter values; do not
  base authorization or uniqueness on cached fields.
- Test changed application behavior with focused RSpec examples, including meaningful failure and boundary cases.
  Keep minimal factories and explicit scenario relationships; complete generator placeholders as behavior is added.
  WebMock blocks external HTTP: stub the application's external requests explicitly.
- Complete the privacy/terms drafts against actual practices before inviting users and retain their license
  attribution. Configure production domain policy; Render checks `/ready`, and Docker uses `/up` for liveness.
  Read DEPLOY.md before adding availability monitoring: the Free default intentionally sleeps.
