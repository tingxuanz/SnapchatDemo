//
//  RtoL.swift
//  NewCookieChat
//
//  Created by Chao Liang on 16/10/16.
//  Copyright © 2016 Chao. All rights reserved.
//

import UIKit

class toLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { dst.view.transform = CGAffineTransform(translationX: 0, y: 0)},
                       completion: { finished in src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
class toRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { dst.view.transform = CGAffineTransform(translationX: 0, y: 0)},
                       completion: { finished in src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
class toUp: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: dst.view.frame.size.height)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { dst.view.transform = CGAffineTransform(translationX: 0, y: 0)},
                       completion: { finished in src.present(dst, animated: false, completion: nil)
            }
        )
    }
}
class toDown: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -dst.view.frame.size.height)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { dst.view.transform = CGAffineTransform(translationX: 0, y: 0)},
                       completion: { finished in src.present(dst, animated: false, completion: nil)
            }
        )
    }
}

class UnwindFromRight: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                                   animations: { src.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)},
                                   completion: { finished in src.dismiss(animated: false, completion: nil)
            }
        )
    }
}

class UnwindFromLeft: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(src.view, belowSubview: dst.view)
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { src.view.transform = CGAffineTransform(translationX: -(src.view.frame.size.width), y: 0)},
                       completion: { finished in src.dismiss(animated: false, completion: nil)
            }
        )
    }
}
class UnwindFromUp: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(src.view, belowSubview: dst.view)
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { src.view.transform = CGAffineTransform(translationX: 0, y: dst.view.frame.size.height)},
                       completion: { finished in src.dismiss(animated: false, completion: nil)
            }
        )
    }
}

class UnwindFromDown: UIStoryboardSegue {
    
    override func perform()
    {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(src.view, belowSubview: dst.view)
        src.view.transform = CGAffineTransform(translationX: 0, y: 0)
        
        UIView.animate(withDuration: 0.70, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut,
                       animations: { src.view.transform = CGAffineTransform(translationX: 0, y: -dst.view.frame.size.height)},
                       completion: { finished in src.dismiss(animated: false, completion: nil)
            }
        )
    }
}
