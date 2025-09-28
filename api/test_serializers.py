from django.test import TestCase
from api.models import Note
from api.serializers import NoteSerializer


class NoteSerializerTest(TestCase):
    def setUp(self):
        self.note = Note.objects.create(body="This is a test note.")

    def test_serialized_fields(self):
        """Serializer should return all fields defined in model"""
        serializer = NoteSerializer(self.note)
        data = serializer.data
        self.assertIn("id", data)
        self.assertIn("body", data)
        self.assertIn("created", data)
        self.assertIn("updated", data)
        self.assertEqual(data["body"], "This is a test note.")

    def test_valid_data_creates_note(self):
        """Serializer should validate and create a note with valid data"""
        data = {"body": "New note body"}
        serializer = NoteSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        note = serializer.save()
        self.assertEqual(note.body, "New note body")

    def test_empty_data_creates_note(self):
        """Serializer should allow empty data because body is nullable/blank"""
        serializer = NoteSerializer(data={})
        self.assertTrue(serializer.is_valid())
        note = serializer.save()
        self.assertIsNone(note.body)  
