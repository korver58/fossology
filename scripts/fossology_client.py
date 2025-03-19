import argparse
import datetime
from typing import Any, Dict, List

import requests


class RestApiClient:
    def __init__(self, base_url: str, headers: Dict[str, str] | None = None):
        self.base_url = base_url.rstrip("/")
        self.session = requests.Session()
        self.session.headers.update(headers or {})

    def set_auth_token(self, token: str):
        self.session.headers.update({"Authorization": f"Bearer {token}"})

    def _log(self, message: str):
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {message}")

    def _request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        try:
            self._log(f"{method} request to {url} with {kwargs}")

            response = self.session.request(method, url, **kwargs)
            response.raise_for_status()

            # レスポンスがJSONならパースして返す
            if response.headers.get("Content-Type", "").startswith("application/json"):
                self._log(f"Response: {response.status_code} (JSON)")
                return response.json()

            self._log(f"Response: {response.status_code} (Text)")
            return {"status_code": response.status_code, "content": response.text}

        except requests.exceptions.RequestException as e:
            self._log(f"Error: {method} {url} → {e}")
            return None
        except Exception as e:
            self._log(f"Unexpected Error: {method} {url} → {e}")
            raise

    def get(self, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        return self._request("GET", endpoint, **kwargs)

    def post(self, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        return self._request("POST", endpoint, **kwargs)

    def put(self, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        return self._request("PUT", endpoint, **kwargs)

    def patch(self, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        return self._request("PATCH", endpoint, **kwargs)

    def delete(self, endpoint: str, **kwargs) -> Dict[str, Any] | List[Any] | None:
        return self._request("DELETE", endpoint, **kwargs)


def main():
    parser = argparse.ArgumentParser(description="Black Duck API Client")
    parser.add_argument("--url", required=True, help="Black Duck URL")
    parser.add_argument("--token", required=True, help="API Token")
    parser.add_argument("--list-projects", action="store_true", help="List all projects")
    parser.add_argument("--list-versions", type=str, help="List versions of a project")
    parser.add_argument("--scan", type=str, help="Run scan for a project")
    parser.add_argument("--scan-version", type=str, default="latest", help="Scan version")
    parser.add_argument("--scan-dir", type=str, default=".", help="Directory to scan")
    parser.add_argument("--delete-version", type=str, help="Delete a project version")
    args = parser.parse_args()

    client = RestApiClient(args.url, args.token)

    if args.list_projects:
        bd_api.list_projects()
    elif args.list_versions:
        bd_api.list_project_versions(args.list_versions)
    elif args.scan:
        bd_api.run_scan(args.scan, args.scan_version, args.scan_dir)
    elif args.delete_version:
        bd_api.delete_version(args.delete_version, args.scan_version)


if __name__ == "__main__":
    main()
