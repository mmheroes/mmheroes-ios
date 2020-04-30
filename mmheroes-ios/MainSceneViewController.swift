import UIKit

final class MainSceneViewController: UIViewController {

    @IBOutlet var gameView: GameView!

    private var runner: GameRunner?
    private var renderer: UIKitMMHeroesRenderer?
    private var gameThread: Thread?

    private var rendered: NSMutableAttributedString?

    private var font = UIFont(name: "Menlo", size: 12)!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpKeyCommands()

        setUpGame()

        gameView.didRedraw = { [weak self] in
            self?.renderer?.viewDidFinishRedrawing()
        }
    }

    private func setUpGame() {
        let renderer = UIKitMMHeroesRenderer(font: font) { [weak self] result in
            DispatchQueue.main.async {
                self?.gameView.content = result
                self?.gameView.font = self?.font
                self?.gameView.setNeedsDisplay()
            }
        }
        self.renderer = renderer

        let runner = GameRunner(renderer: renderer)
        self.runner = runner

        let gameThread = Thread {
            var generator = SystemRandomNumberGenerator()
            while true {
                try! runner.run(seed: generator.next(), mode: MMHEROES_GameMode_God)
            }
        }

        gameThread.name = "mmheroes-game-loop"

        self.gameThread = gameThread

        gameThread.start()
    }

    private func setUpKeyCommands() {

        let basicKeyCommands = [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow,
                         modifierFlags: [],
                         action: #selector(moveUp(_:))),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow,
                         modifierFlags: [],
                         action: #selector(moveDown(_:))),
            UIKeyCommand(input: "\r",
                         modifierFlags: [],
                         action: #selector(confirm(_:))),
        ]

        basicKeyCommands.forEach(addKeyCommand)

        func registerAnyKeyCommand(_ input: String) {
            addKeyCommand(UIKeyCommand(input: input,
                                       modifierFlags: [],
                                       action: #selector(anyKey(_:))))
        }

        registerAnyKeyCommand(UIKeyCommand.inputEscape)
        registerAnyKeyCommand(UIKeyCommand.inputLeftArrow)
        registerAnyKeyCommand(UIKeyCommand.inputRightArrow)
        registerAnyKeyCommand(UIKeyCommand.inputPageUp)
        registerAnyKeyCommand(UIKeyCommand.inputPageDown)
        if #available(iOS 13.4, *) {
            registerAnyKeyCommand(UIKeyCommand.f1)
            registerAnyKeyCommand(UIKeyCommand.f2)
            registerAnyKeyCommand(UIKeyCommand.f3)
            registerAnyKeyCommand(UIKeyCommand.f4)
            registerAnyKeyCommand(UIKeyCommand.f5)
            registerAnyKeyCommand(UIKeyCommand.f6)
            registerAnyKeyCommand(UIKeyCommand.f7)
            registerAnyKeyCommand(UIKeyCommand.f8)
            registerAnyKeyCommand(UIKeyCommand.f9)
            registerAnyKeyCommand(UIKeyCommand.f10)
            registerAnyKeyCommand(UIKeyCommand.f11)
            registerAnyKeyCommand(UIKeyCommand.f12)
            registerAnyKeyCommand(UIKeyCommand.inputHome)
            registerAnyKeyCommand(UIKeyCommand.inputEnd)
        }

        for asciiCode in 1 ..< (128 as UInt8) {
            if asciiCode == 0x0D {
                // We've already handled "\r".
                continue
            }
            registerAnyKeyCommand(String(UnicodeScalar(asciiCode)))
        }
    }

    @IBAction func moveUp(_ sender: Any) {
        renderer?.sendInput(MMHEROES_Input_KeyUp)
    }

    @IBAction func moveDown(_ sender: Any) {
        renderer?.sendInput(MMHEROES_Input_KeyDown)
    }

    @IBAction func confirm(_ sender: Any) {
        renderer?.sendInput(MMHEROES_Input_Enter)
    }

    @objc func anyKey(_ sender: Any) {
        renderer?.sendInput(MMHEROES_Input_Other)
    }

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        // TODO: Save game state so that it could be resumed later
    }

    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        // TODO
    }
}
