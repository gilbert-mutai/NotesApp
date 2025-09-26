import { useState } from 'react'
import './App.css'
import Header from './components/Header.jsx'
import NotesListPage from './pages/NotesListPage'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <Header />
      <NotesListPage />
    </>
  )
}

export default App
