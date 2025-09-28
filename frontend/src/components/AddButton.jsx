import React from 'react';
import { Link } from 'react-router-dom';
import AddIcon from '../assets/add.svg';

const AddButton = () => {
  return (
    <Link to="/note/new" className="floating-button">
      <img src={AddIcon} alt="Add" />
    </Link>
  );
};

export default AddButton;
