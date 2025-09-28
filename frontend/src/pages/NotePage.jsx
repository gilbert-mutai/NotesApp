import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ArrowLeft from '../assets/arrow-left.svg';
import { getCookie } from '../utils/csrf'; 

const NotePage = () => {
  const { id: noteId } = useParams();
  const navigate = useNavigate();
  const [note, setNote] = useState(null);

  useEffect(() => {
    getNote();
  }, [noteId]);

  const getNote = async () => {
    if (noteId === 'new') {
      setNote({ body: '' });
      return;
    }
    try {
      const response = await fetch(`/api/notes/${noteId}/`);
      if (!response.ok) throw new Error('Failed to fetch note');
      const data = await response.json();
      setNote(data);
    } catch (error) {
      console.error('Error fetching note:', error);
    }
  };

  const createNote = async () => {
    await fetch(`/api/notes/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': getCookie('csrftoken'), 
      },
      body: JSON.stringify(note),
    });
  };

  const updateNote = async () => {
    await fetch(`/api/notes/${noteId}/`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': getCookie('csrftoken'),
      },
      body: JSON.stringify(note),
    });
  };

  const deleteNote = async () => {
    await fetch(`/api/notes/${noteId}/`, {
      method: 'DELETE',
      headers: {
        'X-CSRFToken': getCookie('csrftoken'), 
      },
    });
    navigate('/');
  };

  const handleSubmit = async () => {
    if (noteId !== 'new' && (!note?.body || note.body.trim() === '')) {
      await deleteNote();
    } else if (noteId !== 'new') {
      await updateNote();
    } else if (noteId === 'new' && note?.body?.trim() !== '') {
      await createNote();
    }
    navigate('/');
  };

  const handleChange = (e) => {
    setNote({ ...note, body: e.target.value });
  };

  if (!note) return <div>Loading...</div>;

  return (
    <div className="note">
      <div className="note-header">
        <h3>
          <img src={ArrowLeft} alt="Back" onClick={handleSubmit} style={{ cursor: "pointer" }} />
        </h3>
        {noteId !== 'new' ? (
          <button onClick={deleteNote}>Delete</button>
        ) : (
          <button onClick={handleSubmit}>Done</button>
        )}
      </div>

      <textarea
        onChange={handleChange}
        value={note?.body || ''}
      ></textarea>
    </div>
  );
};

export default NotePage;
