import React, { useState } from "react";
import './LoginSignup.css'

const LoginSignup = () => {
    const [action, setAction] = useState("Sign Up");
    
    return (
        <div className='container'>
            <div className='header'>
                <div className='text'>
                    {action}
                </div>
                <div className='underline'></div>
            </div>
            <div className='inputs'>
                <div className='input'>
                    <label htmlFor='address' className='form-label'>
                        Name
                    </label>
                    <input type='text' />
                </div>
            </div>
            <div className='inputs'>
                <div className='input'>
                    <label htmlFor='address' className='form-label'>
                        Email
                    </label>
                    <input type='email' />
                </div>
            </div>  
            <div className='inputs'>
                <div className='input'>
                    <label htmlFor='address' className='form-label'>
                        Password
                    </label>
                    <input type='password' />
                </div>
            </div>
            <div className="submit-container">
                <div className={action === "Login" ? "submit gray" : "submit"} onClick={ () => (setAction("Sign Up"))}>Sign Up</div>
                <div className={action === "Sign Up" ? "submit gray" : "submit"} onClick={ () => (setAction("Login"))}>Login</div>
            </div>             
        </div>
    )
}

export default LoginSignup