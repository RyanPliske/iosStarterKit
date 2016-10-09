import UIKit.UIView

public class KeyboardListeningView: UIView {
    
    public init() {
        super.init(frame: CGRectZero)
        startObserving()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        startObserving()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startObserving()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    // MARK - Private Helper Methods
    
    private func startObserving() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    @objc private func keyboardWillChangeFrame(sender: NSNotification) {
        self.keyboardFrameChange(withNotification: sender)
    }
    
    private func keyboardFrameChange(withNotification notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            if let firstResponder = findFirstResponder() {
                animateIfNeeded(firstResponder, keyboardFrame: keyboardFrame)
            }
        }
    }
    
    private func findFirstResponder() -> UIView? {
        if self.isFirstResponder() {
            return nil
        } else {
            let possibleFirstResponder = self.subviews.filter({ $0.isFirstResponder() }).first
            return possibleFirstResponder
        }
    }
    
    private func animateIfNeeded(focusedView: UIView, keyboardFrame: CGRect) {
        let animateDuration:Double = 0.5
        
        if keyboardFrame.origin.y > self.frame.origin.y + self.frame.height {
            UIView.animateWithDuration(animateDuration, animations: { [weak self] in
                self?.frame.origin.y = 0
            })
        } else {
            let focusedFrame = self.convertRect(focusedView.bounds, fromView: focusedView)
            let padding: CGFloat = 20
            var shiftYPixels = (focusedFrame.origin.y + focusedFrame.size.height + padding) - keyboardFrame.origin.y
            
            if self.frame.origin.y >= 0  && shiftYPixels < 0 {
                shiftYPixels = 0
            } else if self.frame.origin.y < 0 {
                if shiftYPixels > 0 {
                    shiftYPixels = self.frame.origin.y + shiftYPixels
                } else {
                    shiftYPixels += self.frame.origin.y
                    if abs(shiftYPixels) > abs(self.frame.origin.y) {
                        shiftYPixels = self.frame.origin.y
                    }
                }
            }
            if shiftYPixels > keyboardFrame.height + self.frame.origin.y {
                shiftYPixels = keyboardFrame.height + self.frame.origin.y
            }
            UIView.animateWithDuration(animateDuration, animations: { [weak self] in
                self?.frame.origin.y -= shiftYPixels
            })
        }
    }
    
}