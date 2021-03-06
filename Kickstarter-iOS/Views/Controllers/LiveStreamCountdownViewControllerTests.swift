import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
@testable import LiveStream

internal final class LiveStreamCountdownViewControllerTests: TestCase {

  override func setUp() {
    super.setUp()
    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testStandardView() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 19
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: true)
      |> LiveStreamEvent.lens.name .~ "Title of the live stream goes here and can be 60 chr max"
      |> LiveStreamEvent.lens.description .~ ("175 char max. 175 char max 175 char max message with " +
        "a max character count. Hi everyone! We’re doing an exclusive performance of one of our new tracks!")
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    AppEnvironment.replaceCurrentEnvironment(liveStreamService: liveStreamService)

    let devices = [Device.phone4_7inch, Device.phone5_8inch, Device.pad]
    let orientations = [Orientation.landscape, .portrait]

    combos(Language.allLanguages, devices, orientations).forEach { lang, device, orientation in
      withEnvironment(language: lang) {
        let vc = LiveStreamCountdownViewController.configuredWith(project: .template,
                                                                  liveStreamEvent: liveStreamEvent,
                                                                  refTag: .projectPage,
                                                                  presentedFromProject: false)

        let (parent, _) = traitControllers(device: device, orientation: orientation, child: vc)
        self.scheduler.advance()

        FBSnapshotVerifyView(
          parent.view, identifier: "lang_\(lang)_device_\(device)_orientation_\(orientation)"
        )
      }
    }
  }

  func testView_WhenPresentedFromProject() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 19
    let liveStreamEvent = .template
      |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
      |> LiveStreamEvent.lens.user .~ LiveStreamEvent.User(isSubscribed: true)
      |> LiveStreamEvent.lens.name .~ "Title of the live stream."
      |> LiveStreamEvent.lens.description .~ "Short description of the live stream."
    let liveStreamService = MockLiveStreamService(fetchEventResult: .success(liveStreamEvent))

    AppEnvironment.replaceCurrentEnvironment(liveStreamService: liveStreamService)

    let vc = LiveStreamCountdownViewController.configuredWith(project: .template,
                                                              liveStreamEvent: liveStreamEvent,
                                                              refTag: .projectPage,
                                                              presentedFromProject: true)

    let (parent, _) = traitControllers(device: .phone4_7inch, orientation: .portrait, child: vc)
    self.scheduler.advance()

    FBSnapshotVerifyView(parent.view)
  }
}
