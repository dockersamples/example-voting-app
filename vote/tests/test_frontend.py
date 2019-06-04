from app import app
from flask import url_for
import unittest


class VoteUnitTest(unittest.TestCase):

    def setUp(self):
        """Unit Test Setup"""
        self.app = app.test_client()
        self.app.testing = True


    def test_home_status_code(self):
        """Assert that the home page loads successfully"""
        result = self.app.get('/')
        self.assertEqual(result.status_code, 200)

    def test_version_is_set(self):
        """Assert that version is set"""
        result = self.app.get('/')
        assert 'Version' in str(result.data)

    def test_processed_by_is_set(self):
        """Assert that processed by string is set"""
        result = self.app.get('/')
        assert 'Processed by' in str(result.data)

if __name__ == '__main__':
    unittest.main()
