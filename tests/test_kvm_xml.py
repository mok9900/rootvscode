import importlib.util
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET

SCRIPT = Path(__file__).resolve().parents[1] / "verify_kvm_xml.py"
spec = importlib.util.spec_from_file_location("kvmxml", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class KVMXMLTests(unittest.TestCase):
    def test_capabilities_accept_kvm(self):
        xml = ET.fromstring("<capabilities><guest><arch name='x86_64'><domain type='kvm'/></arch></guest></capabilities>")
        self.assertTrue(module.is_kvm_xml("capabilities", xml))

    def test_capabilities_reject_qemu_tcg(self):
        xml = ET.fromstring("<capabilities><guest><arch name='x86_64'><domain type='qemu'/></arch></guest></capabilities>")
        self.assertFalse(module.is_kvm_xml("capabilities", xml))

    def test_domcapabilities_accept_kvm(self):
        self.assertTrue(module.is_kvm_xml("domcapabilities", ET.fromstring("<domainCapabilities><domain>kvm</domain></domainCapabilities>")))

    def test_domcapabilities_reject_qemu(self):
        self.assertFalse(module.is_kvm_xml("domcapabilities", ET.fromstring("<domainCapabilities><domain>qemu</domain></domainCapabilities>")))

    def test_domain_reject_qemu(self):
        self.assertFalse(module.is_kvm_xml("domain", ET.fromstring("<domain type='qemu'><name>vm</name></domain>")))

    def test_domain_accept_kvm(self):
        self.assertTrue(module.is_kvm_xml("domain", ET.fromstring("<domain type='kvm'><name>vm</name></domain>")))


if __name__ == "__main__":
    unittest.main()
