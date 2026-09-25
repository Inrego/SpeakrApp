# Screenshots

All screenshots are captured from the real app against the invented dataset in
[`tools/mock-server`](../../tools/mock-server/README.md), so there's no real data in them.
The project [`README.md`](../../README.md) shows one per platform (the recordings list);
the full set is below.

| Screen | Android | Windows |
| --- | --- | --- |
| Recordings list | <img src="mobile-library.png" width="200" /> | <img src="desktop-library.png" width="420" /> |
| Recording detail | <img src="mobile-detail.png" width="200" /> | <img src="desktop-detail.png" width="420" /> |
| Live capture | <img src="mobile-live.png" width="200" /> | <img src="desktop-live.png" width="420" /> |
| Settings | <img src="mobile-settings.png" width="200" /> | <img src="desktop-settings.png" width="420" /> |
| Onboarding | <img src="mobile-onboarding.png" width="200" /> | <img src="desktop-onboarding.png" width="420" /> |

## Notes

- Android shots are the Google Play listing screenshots: 1080 × 2400, Medium Phone API 36.1
  AVD, profile build. See [`../play-store/checklist.md`](../play-store/checklist.md).
- Windows shots are 2880 × 1800: a 1440 × 900 window at 2× pixel ratio, captured from a
  debug build via a throwaway `integration_test` harness.
- `mobile.png` duplicates `mobile-detail.png`. It's kept only because the Play docs refer to it;
  don't upload it to the Play Console.
