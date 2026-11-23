import unittest
import os
import sys
import tempfile
import json
from unittest.mock import patch, MagicMock

real_cli_path = os.path.realpath(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "bin", "septober-cli-26")))

import importlib.machinery
loader = importlib.machinery.SourceFileLoader("septober_cli_26", real_cli_path)
import types
cli = types.ModuleType(loader.name)
loader.exec_module(cli)

class TestSeptoberCli26(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.yaml_file = os.path.join(self.temp_dir.name, ".septober.yml")
        with open(self.yaml_file, "w") as f:
            f.write("""
local:
  site: "http://localhost:8080/api/"
  user: "guest"
  password: "guest_password"
production:
  site: "https://example.com/api/"
  user: "prod_user"
  password: "prod_password"
""")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_load_config_default(self):
        cfg = cli.load_config(self.yaml_file)
        self.assertIn("site", cfg)
        self.assertIn("user", cfg)
        self.assertIn("password", cfg)

    def test_load_config_env_override(self):
        with patch.dict(os.environ, {
            "SEPTOBER_SITE": "http://custom-host:9999/api/",
            "SEPTOBER_USER": "custom_user",
            "SEPTOBER_PASSWORD": "custom_password"
        }):
            cfg = cli.load_config(self.yaml_file)
            self.assertEqual(cfg["site"], "http://custom-host:9999/api/")
            self.assertEqual(cfg["user"], "custom_user")
            self.assertEqual(cfg["password"], "custom_password")

    def test_format_priority(self):
        self.assertIn("Urgent", cli.format_priority(5))
        self.assertIn("High", cli.format_priority(4))
        self.assertIn("Med", cli.format_priority(3))
        self.assertIn("Low", cli.format_priority(2))
        self.assertIn("Backlog", cli.format_priority(1))

    @patch("urllib.request.urlopen")
    def test_make_request_success(self, mock_urlopen):
        mock_resp = MagicMock()
        mock_resp.status = 200
        mock_resp.read.return_value = json.dumps([{"id": 1, "name": "Test todo"}]).encode("utf-8")
        mock_urlopen.return_value.__enter__.return_value = mock_resp

        cfg = {"site": "http://localhost:8080/api/", "user": "test", "password": "pwd"}
        res = cli.make_request(cfg, "todos.json")
        self.assertEqual(res["status"], 200)
        self.assertEqual(len(res["data"]), 1)
        self.assertEqual(res["data"][0]["name"], "Test todo")

    def test_load_config_agent_profile(self):
        with open(self.yaml_file, "w") as f:
            f.write("""
local:
  site: "http://localhost:8080/api/"
  user: "guest"
  password: "guest_password"
agents:
  ermete:
    user: "rcarlesso.ermete"
    password: "pwd-ermete"
    icon: "🚛"
    host: "mini-lobby"
  lobby:
    user: "rcarlesso.lobby"
    password: "pwd-lobby"
    icon: "🦞"
    host: "mini-lobby"
""")
        cfg_ermete = cli.load_config(self.yaml_file, target_agent="ermete")
        self.assertEqual(cfg_ermete["user"], "rcarlesso.ermete")
        self.assertEqual(cfg_ermete["password"], "pwd-ermete")
        self.assertEqual(cfg_ermete["agent"], "ermete")
        self.assertEqual(cfg_ermete["agent_icon"], "🚛")

        cfg_lobby = cli.load_config(self.yaml_file, target_agent="lobby")
        self.assertEqual(cfg_lobby["user"], "rcarlesso.lobby")
        self.assertEqual(cfg_lobby["password"], "pwd-lobby")
        self.assertEqual(cfg_lobby["agent"], "lobby")
        self.assertEqual(cfg_lobby["agent_icon"], "🦞")

    def test_load_config_agent_auto_detect_from_harness(self):
        with open(self.yaml_file, "w") as f:
            f.write("""
local:
  site: "http://localhost:8080/api/"
  user: "guest"
  password: "guest_password"
agents:
  ermete:
    user: "rcarlesso.ermete"
    password: "pwd-ermete"
    icon: "🚛"
    host: "mini-lobby"
""")
        with patch.dict(os.environ, {"HARNESS_NAME": "Hermes"}, clear=False):
            cfg = cli.load_config(self.yaml_file)
            self.assertEqual(cfg["user"], "rcarlesso.ermete")
            self.assertEqual(cfg["agent"], "ermete")

if __name__ == "__main__":
    unittest.main()
