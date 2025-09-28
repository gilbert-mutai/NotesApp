from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from api.models import Note


class NoteViewTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.note1 = Note.objects.create(body="First note")
        self.note2 = Note.objects.create(body="Second note")

    def test_list_notes(self):
        response = self.client.get("/api/notes/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        self.assertEqual(response.data[0]["body"], "Second note") 

    def test_create_note(self):
        response = self.client.post("/api/notes/", {"body": "New note"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)  
        self.assertEqual(Note.objects.count(), 3)
        self.assertEqual(response.data["body"], "New note")

    def test_get_note_detail(self):
        response = self.client.get(f"/api/notes/{self.note1.id}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["body"], "First note")

    def test_update_note(self):
        response = self.client.put(
            f"/api/notes/{self.note1.id}/", {"body": "Updated body"}, format="json"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.note1.refresh_from_db()
        self.assertEqual(self.note1.body, "Updated body")

    def test_delete_note(self):
        response = self.client.delete(f"/api/notes/{self.note1.id}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Note.objects.count(), 1)
        self.assertEqual(response.data, "Note was deleted!")
