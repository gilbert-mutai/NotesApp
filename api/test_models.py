from django.test import TestCase
from api.models import Note 


class NoteModelTest(TestCase):
    def setUp(self):
        self.note = Note.objects.create(body="This is a test note for model testing.")

    def test_str_representation(self):
        """__str__ should return first 50 characters of body"""
        self.assertEqual(str(self.note), "This is a test note for model testing.")

    def test_str_truncation(self):
        """__str__ should truncate long body text to 50 characters"""
        long_body = "a" * 100  # 100 characters long
        note = Note.objects.create(body=long_body)
        self.assertEqual(str(note), "a" * 50)

    def test_auto_timestamps(self):
        """created should not be None and updated should auto-update"""
        self.assertIsNotNone(self.note.created)
        self.assertIsNotNone(self.note.updated)

    def test_update_changes_updated_field(self):
        """updating the note should change updated timestamp"""
        old_updated = self.note.updated
        self.note.body = "Updated body"
        self.note.save()
        self.assertNotEqual(self.note.updated, old_updated)
