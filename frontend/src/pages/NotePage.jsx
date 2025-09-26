import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';

const NotePage = () => {
  const { id } = useParams(); // get the :id from the route
  const [note, setNote] = useState(null);

  useEffect(() => {
    getNote();
  }, [id]); // add id as dependency

  const getNote = async () => {
    try {
      const response = await fetch(`/api/notes/${id}/`);
      const data = await response.json();
      setNote(data);
    } catch (error) {
      console.error('Error fetching note:', error);
    }
  };

  return (
    <div>
      <p>{note?.body}</p>
    </div>
  );
};

export default NotePage;
