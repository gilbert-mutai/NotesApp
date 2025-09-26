import React, {useState, useEffect} from 'react'

const NotesListPage = () => {
  let [notes, setNotes] = useState([])

  useEffect(() => {
    getNotes()
  }, [])

  let getNotes = async () => {
    let response = await fetch('http://localhost:8000/api/notes/')
    let data = await response.json()
    console.log('DATA:', data)
    setNotes(data)
  }

  return (
    <div>
      <div className='notes-list'>
        {notes.map((note, index) => (
          <h3 key={index}>{note.body}</h3>
        ))}
      </div>
    </div>
  )
}

export default NotesListPage
