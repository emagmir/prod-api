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
    const response = await api.get('/users/');
    setTransactions(response.data)
  };

  useEffect(() => {
    fetchTransactions();
  }, [])

  const handleInputChange = (event) => {
    const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    setFormData({
      ...formData,
      [event.target.name]: value,
    });
  };
  

  const handleFormSubmit = async (event) => {
    event.preventDefault();
    await api.post('/users/', formData);
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
          <div className='mb-3 mt-3'>
            <label htmlFor='name' className='form-label'>
              Name
            </label>
            <input type='text' className='form-control' id='name' name='name' onChange={handleInputChange} value={formData.name}/>
          </div>

          <div className='mb-3'>
            <label htmlFor='email' className='form-label'>
              Email
            </label>
            <input type='text' className='form-control' id='email' name='email' onChange={handleInputChange} value={formData.email}/>
          </div>

          <div className='mb-3'>
            <label htmlFor='address' className='form-label'>
              Address
            </label>
            <input type='text' className='form-control' id='address' name='address' onChange={handleInputChange} value={formData.address}/>
          </div>

          <button type='submit' className='btn btn-primary'>
            Submit
          </button>

        </form>

        <table className='table table-striped table-bordered table-hover'>
          <thead>
            <tr>
              <th>
                Name
              </th>
              <th>
                Email
              </th>
              <th>
                Address
              </th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((transaction) => (
              <tr key={transaction.id}>
                <td>{transaction.name}</td>
                <td>{transaction.email}</td>
                <td>{transaction.address}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>    
    </div>
  )
}

export default App;