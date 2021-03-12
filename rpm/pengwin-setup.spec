#
# spec file for package pengwin-setup
#
# Copyright (c) 2019 Whitewater Foundry, Ltd. Co. <contact@whitewaterfoundry.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

Name:           pengwin-setup
Summary:        Setup tool for Pengwin
Version:        1.0.0
Release:        3%{?dist}
Source:         %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       wslu
URL:            https://github.com/WhitewaterFoundry/pengwin-setup
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
License:        MIT

%description
This package contains the setup tool for Pengwin.

%prep
%setup -q -n %{name}

%build

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/pengwin-setup.d
mkdir -p %{buildroot}%{_datadir}/bash-completion/completions

install -p -m 755 fedora/login_shell %{buildroot}%{_bindir}
install -p -m 755 fedora/pengwin-setup %{buildroot}%{_bindir}
cp -a fedora/pengwin-setup.d/* %{buildroot}%{_datadir}/pengwin-setup.d
chmod -R 755 %{buildroot}%{_datadir}/pengwin-setup.d
install -m 755 completions/pengwin-setup %{buildroot}%{_datadir}/bash-completion/completions

%post
echo "Type pengwin-setup to launch the Pengwin setup utility."

%files
%defattr(-,root,root)
%doc LICENSE
%dir %{_datadir}/pengwin-setup.d
%{_datadir}/pengwin-setup.d/*
%{_bindir}/login_shell
%{_bindir}/pengwin-setup
%{_datadir}/bash-completion/completions/pengwin-setup

%changelog
* Tue Feb 16 2021 Sascha Manns <sascha@whitewaterfoundry.com> - 1.0.0-3
Moved Fedora modifications to top level dir 'fedora'

* Thu Feb 11 2021 Sascha Manns <sascha@whitewaterfoundry.com> - 1.0.0-2
Updated to follow the FHS

* Tue Feb 9 2021 Sascha Manns <sascha@whitewaterfoundry> - 1.0.0-1
Initial release of the Fedora package
