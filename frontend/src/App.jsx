import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { useState } from 'react';
import './App.css';
import Header from './components/Header.jsx';
import NotesListPage from './pages/NotesListPage';
import NotePage from './pages/NotePage'

function App() {
  const [count, setCount] = useState(0);

  return (
    <Router>
      <div className="container dark">
        <div className="app">
        <Header />
        <Routes>
          <Route path="/" element={<NotesListPage />} />
          <Route path="/note/:id" element={<NotePage />} />
        </Routes>
      </div>
      </div>

    </Router>
  );
}

export default App;
