//
//  Promise.swift
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

import Foundation

class Promise {
    // An array of callbacks (Void -> Void) to iterate through at resolve time.
    var pending: (() -> ())[] = []
    
    // A callback to call when we're completely done.
    var done: (() -> ()) = {}
    
    // A callback to invoke in the event of failure.
    var fail: (() -> ()) = {}
    
    // A simple way to track rejection.
    var rejected: Bool = false
    
    // Class ("static") method to return a new promise.
    class func defer() -> Promise {
        return Promise()
    }
    
    // Resolve method.
    //
    // Returns a resolve function that loops through pending callbacks,
    // invoking each in sequence.
    //
    // Invokes fail callback in case of rejection (and swiftly abandons ship).
    func resolve() -> (() -> ()) {
        func resolve() -> () {
            for f in self.pending {
                if self.rejected {
                    fail()
                    return
                }
                f()
            }
            if self.rejected {
                fail()
                return
            }
            done()
        }
        return resolve
    }
    
    // Reject method.
    //
    // Sets rejection flag to true to halt execution of subsequent callbacks.
    func reject() -> () {
        self.rejected = true
    }
    
    // Then method.
    //
    // This lets us chain callbacks together; it accepts one parameter, a Void -> Void
    // callback - can either be a function itself, or a Swift closure.
    func then(callback: (() -> ())) -> Promise {
        self.pending.append(callback)
        return self
    }
    
    // Then method override.
    //
    // This also lets us chain callbacks together; it accepts one parameter,
    // but unlike the previous implementation of then(), it accepts a Promise -> Void
    // callback (which can either be a function itself, or a Swift closure).
    //
    // This method then wraps that callback in a Void -> Void callback that
    // passes in this Promise object when invoking the callback() function.
    //
    // This allows users of our Promise library to have access to the Promise object,
    // so that they can reject a Promise within their then() clauses. Not the cleanest
    // way, but hey, this whole thing is a proof of concept, right? :)
    func then(callback: ((promise: Promise) -> ())) -> Promise {
        func thenWrapper() -> () {
            callback(promise: self)
        }
        self.pending.append(thenWrapper)
        return self
    }
    
    // Fail method.
    //
    // This lets us chain a fail() method at the end of a set of then() clauses.
    func fail(fail: (() -> ())) -> Promise {
        self.fail = fail
        return self
    }
    
    // Done method.
    //
    // This lets us specify a done() callback to be invoked at the end of a set
    // of then() clauses (provided the promise hasn't been rejected).
    func done(done: (() -> ())) -> () {
        self.done = done
    }
}