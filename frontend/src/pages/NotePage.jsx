import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import ArrowLeft from '../assets/arrow-left.svg'; 

const NotePage = () => {
  const { id } = useParams();
  const [note, setNote] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getNote();
  }, [id]);

  const getNote = async () => {
    setLoading(true);
    try {
      const response = await fetch(`/api/notes/${id}/`);
      if (!response.ok) throw new Error('Failed to fetch note');
      const data = await response.json();
      setNote(data);
    } catch (error) {
      console.error('Error fetching note:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    setNote({ ...note, body: e.target.value });
  };

  if (loading) return <div>Loading...</div>;
  if (!note) return <div>Note not found</div>;

  return (
    <div className='note'>
      <div className='note-header'>
        <h3>
          <Link to="/">
            <img src={ArrowLeft} alt="Back" />
          </Link>
        </h3>
      </div>

      <textarea
        value={note.body || ''}
        onChange={handleChange}
      />
    </div>
  );
};

export default NotePage;
