import pytest

def test_package_pg12(host):
    pkg = host.package("postgresql12-server")
    assert pkg.is_installed
def test_package_pg13(host):
    pkg = host.package("postgresql13-server")
    assert pkg.is_installed

def test_service_test(host):
    svc = host.service("postgresql-13@artifactory_test")
    assert svc.is_running
    assert svc.is_enabled
def test_service_accp(host):
    svc = host.service("postgresql-12@artifactory_accp")
    assert svc.is_running
    assert svc.is_enabled
def test_service_prod(host):
    svc = host.service("postgresql-12@artifactory_prod")
    assert svc.is_running
    assert svc.is_enabled


