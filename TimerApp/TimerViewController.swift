//
//  TimerViewController.swift
//  TimerApp
//
//  Created by Masato Takamura on 2021/09/26.
//

import UIKit



final class TimerViewController: UIViewController {
    //MARK: - Properties
    //状態
    enum State {
        case invalidate
        case progress
        case pause
    }
    private var state: State = .invalidate
    //タイマー
    private weak var timer: Timer?
    //残り時間
    private var timeLeft: Int = 60
    //残り時間の文字列化
    private var _timeLeft: String {
        return String(format: "%02d:%02d", timeLeft / 60, timeLeft % 60)
    }
    //ピッカーに表示する秒数
    private let timeList: [Int] = [60, 180, 300, 600]
    //選択されているピッカーの行
    private var selectedRow: Int = 0

    //MARK: - Views
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .clear
        picker.tintColor = .white
        picker.setValue(UIColor.white, forKey: "textColor")
        return picker
    }()

    private let timerCirclePathView = TimerCirclePathView()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(
            ofSize: 48,
            weight: .bold
        )
        label.textColor = .white
        label.text = _timeLeft
        return label
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "restart"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .red
        button.addTarget(
            self,
            action: #selector(didTapStartButton(_:)),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "clock.arrow.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .darkGray
        button.addTarget(
            self,
            action: #selector(didTapResetButton(_:)),
            for: .touchUpInside
        )
        return button
    }()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupLayoutConstraints()
        timerCirclePathView.configureCirclePath(
            center: CGPoint(
                x: 200,
                y: 200
            ),
            radius: 150,
            startAngle: 0,
            endAngle: 2 * .pi
        )
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        startButton.layer.cornerRadius = startButton.frame.size.height / 2
        resetButton.layer.cornerRadius = resetButton.frame.size.height / 2
    }

    //MARK: - Private Functions
    ///timerの初期化
    private func initTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(fireTimer),
            userInfo: nil,
            repeats: true
        )
        guard let timer = timer else { return }
        //ズレの許容範囲　Apple推奨は10%以上
        timer.tolerance = 0.15
        //メインスレッドがbusyのとき、手動でスケジューリングが必要
        RunLoop.current.add(timer, forMode: .common)
    }
    ///オートレイアウトの設定
    private func setupLayoutConstraints() {

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            pickerView.heightAnchor.constraint(equalToConstant: 100)
        ])

        timerCirclePathView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerCirclePathView)
        NSLayoutConstraint.activate([
            timerCirclePathView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerCirclePathView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timerCirclePathView.widthAnchor.constraint(equalToConstant: 400),
            timerCirclePathView.heightAnchor.constraint(equalToConstant: 400)
        ])

        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerCirclePathView.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: timerCirclePathView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerCirclePathView.centerYAnchor)
        ])

        let hStack = UIStackView(arrangedSubviews: [resetButton, startButton])
        hStack.axis = .horizontal
        hStack.spacing = 32
        hStack.alignment = .fill
        hStack.distribution = .fillEqually
        hStack.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: timerCirclePathView.bottomAnchor, constant: 32),
            hStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 60),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            resetButton.widthAnchor.constraint(equalToConstant: 60),
            resetButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    func updateUI(state: State) {
        switch state {
        case .invalidate, .pause:
            startButton.setImage(UIImage(systemName: "restart"), for: .normal)
            startButton.backgroundColor = .systemRed
        case .progress:
            startButton.setImage(UIImage(systemName: "stop"), for: .normal)
            startButton.backgroundColor = .systemBlue
        }
    }

}

//MARK: - UIPickerViewDelegate
extension TimerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(timeList[row] / 60)分"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //値の保存
        selectedRow = row
        timeLeft = timeList[selectedRow]
        //更新
        state = .invalidate
        updateUI(state: state)
        timerLabel.text = _timeLeft
        timerCirclePathView.resetAnimation()
    }
}

//MARK: - UIPickerViewDataSource
extension TimerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeList.count
    }
}

//MARK: - @objc Private Extension
@objc
private extension TimerViewController {
    ///timerを発火させる
    func fireTimer() {
        timeLeft -= 1
        timerLabel.text = _timeLeft
        if timeLeft <= 0 {
            state = .invalidate
            timer?.invalidate()
            timer = nil
            updateUI(state: state)
            timeLeft = timeList[selectedRow]
            timerCirclePathView.resetAnimation()
        }
    }

    ///startButtonがタップされたとき
    func didTapStartButton(_ sender: UIButton) {
        switch state {
        case .invalidate:
            state = .progress
            updateUI(state: state)
            //timer start
            initTimer()
            timerCirclePathView.startAnimation(Double(timeLeft))
        case .pause:
            state = .progress
            updateUI(state: state)
            //timer restart
            initTimer()
            timerCirclePathView.resumeAnimation()
        case .progress:
            state = .pause
            updateUI(state: state)
            //timer stop
            guard let timer = timer else { return }
            timer.invalidate()
            timerCirclePathView.pauseAnimation()
        }
    }

    ///resetButtonがタップされたとき
    func didTapResetButton(_ sender: UIButton) {
        state = .invalidate
        timerCirclePathView.resetAnimation()
        updateUI(state: state)
        timeLeft = timeList[selectedRow]
        timerLabel.text = _timeLeft

        guard let timer = timer else { return }
        timer.invalidate()
    }

}
