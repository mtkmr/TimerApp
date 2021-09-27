//
//  TimerViewController.swift
//  TimerApp
//
//  Created by Masato Takamura on 2021/09/26.
//

import UIKit

final class TimerViewController: UIViewController {

    private var isRunning: Bool = false

    //状態を保存する
    private var state: State = .invalidate
    //タイマー
    private weak var timer: Timer?
    //残り時間
    private var timeLeft: Int = 60

    private var _timeLeft: String {
        return String(format: "%02d:%02d", timeLeft / 60, timeLeft % 60)
    }

    private let timeList: [Int] = [60, 180, 300, 600]
    //選択されたピッカーの行
    private var selectedRow: Int = 0


    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = "\(timeList[0] / 60)分"
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 5
        textField.textAlignment = .center

        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self

        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        let doneItem = UIBarButtonItem(
            barButtonSystemItem: .done
            , target: self,
            action: #selector(done)
        )
        toolBar.setItems([doneItem], animated: true)

        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar

        return textField
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
        button.backgroundColor = .lightGray
        button.addTarget(
            self,
            action: #selector(didTapResetButton(_:)),
            for: .touchUpInside
        )
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
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

    private func setupLayoutConstraints() {

        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            textField.heightAnchor.constraint(equalToConstant: 48)
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
            startButton.widthAnchor.constraint(equalToConstant: 40),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            resetButton.widthAnchor.constraint(equalToConstant: 40),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])



    }

}

//MARK: - UIPickerViewDelegate
extension TimerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(timeList[row] / 60)分"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //値の保存
        timeLeft = timeList[row]
        selectedRow = row
        //更新
        textField.text = "\(timeList[row] / 60)分"
        timerLabel.text = _timeLeft

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

    func fireTimer() {
        timeLeft -= 1
        timerLabel.text = _timeLeft
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            timeLeft = timeList[selectedRow]
            state = .invalidate
            startButton.setImage(UIImage(systemName: "restart"), for: .normal)
            startButton.backgroundColor = .red
            timerCirclePathView.reset()
        }
    }


    func didTapStartButton(_ sender: UIButton) {

        switch state {

        case .invalidate:
            state = .progress
            startButton.setImage(UIImage(systemName: "stop"), for: .normal)
            startButton.backgroundColor = .blue
            //timer start
            initTimer()
            timerCirclePathView.startAnimation(Double(timeLeft))
        case .pause:
            state = .progress
            startButton.setImage(UIImage(systemName: "stop"), for: .normal)
            startButton.backgroundColor = .blue
            //timer restart
            initTimer()
            timerCirclePathView.resumeAnimation()
        case .progress:
            state = .pause
            startButton.setImage(UIImage(systemName: "restart"), for: .normal)
            startButton.backgroundColor = .red
            //timer stop
            guard let timer = timer else { return }
            timer.invalidate()
            timerCirclePathView.pauseAnimation()

        }
    }

    func didTapResetButton(_ sender: UIButton) {
        guard
            let timer = timer
        else {
            state = .invalidate
            timerCirclePathView.reset()
            startButton.setImage(UIImage(systemName: "restart"), for: .normal)
            startButton.backgroundColor = .red
            timeLeft = timeList[selectedRow]
            timerLabel.text = _timeLeft
            return
        }
        timer.invalidate()
        state = .invalidate
        timerCirclePathView.reset()
        startButton.setImage(UIImage(systemName: "restart"), for: .normal)
        startButton.backgroundColor = .red
        timeLeft = timeList[selectedRow]
        timerLabel.text = _timeLeft
    }

    func done() {
        textField.endEditing(true)
    }
}
