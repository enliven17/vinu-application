import { useState, useEffect } from 'react'

function App() {
    const [message, setMessage] = useState('Loading...')

    useEffect(() => {
        fetch('/api/message')
            .then(res => res.json())
            .then(data => setMessage(data.message))
            .catch(err => setMessage('Error fetching message'))
    }, [])

    return (
        <div className="min-h-screen bg-gray-100 flex items-center justify-center">
            <div className="bg-white p-8 rounded-lg shadow-md">
                <h1 className="text-2xl font-bold mb-4 text-blue-600">3-Tier App Demo</h1>
                <p className="text-gray-700">Backend says:</p>
                <p className="text-xl font-semibold mt-2 text-green-600">{message}</p>
            </div>
        </div>
    )
}

export default App
