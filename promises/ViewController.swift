//
//  ViewController.swift
//  promises
//
//  Created by Rob Ringham on 6/7/14.
//  Copyright (c) 2014, Rob Ringham
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Example #1
        //
        uploadFile().then({
            // let the user know their file has been uploaded
            println("hooray, your file uploaded!")
        }).then({
            // do something else here
            println("start next file upload, or something equally interesting")
        }).fail({
            // alert the user that their file upload failed miserably
            println("all is lost. accept defeat.")
        }).done({
            // we're done!
            println("all done!")
        })
        
        //
        // Example #2
        //
        uploadFile().then({
            // let the user know their file has been uploaded
            println("hooray, your file uploaded!")
        }).then({(promise: Promise) -> () in
            // something here failed, so lets reject
            // the whole thing and fall through to fail()
            promise.reject()
        }).fail({
            // alert the user that their file upload failed miserably
            println("all is lost. accept defeat.")
        }).done({
            // we're done!
            println("all done!")
        })
    }
    
    func uploadFile() -> Promise {
        let p = Promise.defer()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let success = self.actualFileUpload()
            if !success {
                p.reject()
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                p.resolve()()
                })
            })
        return p
    }

    func actualFileUpload() -> Bool {
        return true
    }
}