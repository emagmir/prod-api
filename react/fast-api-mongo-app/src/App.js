import React, {useState, useEffect} from "react"
import api from './api'

const App = () => {
  const [transactions, setTransactions] = useState([]);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    address : ''
  });

  const fetchTransactions = async () => {
    const response = await api.get('/health/');
    setTransactions(response.data)
  };

  useEffect(() => {
    fetchTransactions();
  }, [])

  /*const handleInputChange = (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
  }
  */

  const handleFormSubmit = async (event) => {
    event.preventDefault();
    await api.post('/health/', formData);
    fetchTransactions();
    setFormData({
      name: '',
      email: '',
      address : ''
    });
  };

  return (
    <div>
      <nav className='navbar navbar-dark bg-primary'>
        <div className='container-fluid'>
          <a className = 'navbar-brand' href="#">
            Cool App
          </a>
        </div>
      </nav>
      <div className='container'>
        <form onSubmit={handleFormSubmit}>
          <div className='mb-3'>
            <label htmlFor='category' className='form-label'>
              Some stuff
            </label>
            <input type='text' className='form-control' id='category' name='category' onchange={handleInputChange} value={formData}/>
          </div>
        </form>
      </div>
    </div>
  )

}

export default App;
