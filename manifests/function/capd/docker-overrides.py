#!/usr/bin/env python

# Copyright 2020 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###################

# docker-overrides.py takes in input a list of providers and, for each of them, generates the components YAML from the
# local repository (airshipctl/manifests/function/capd/v0.3.0), and finally stores it in the clusterctl local override directory
# in ~/.cluster-api

# prerequisites:
# - the script should be executed from airshipctl/manifests/function/capd
# - there should be a airshipctl/manifests/function/capd/clusterctl-settings.json file with the docker provider listed
# {
#    "providers": [ "infrastructure-docker"],
#    "provider_repos": []
# }
#
#
###################

from __future__ import unicode_literals

import json
import subprocess
import os
import errno
import sys

settings = {}

providers = {
      'cluster-api': {
              'componentsFile': 'core-components.yaml',
              'nextVersion': 'v0.3.0',
              'type': 'CoreProvider',
      },
      'bootstrap-kubeadm': {
            'componentsFile': 'bootstrap-components.yaml',
            'nextVersion': 'v0.3.0',
            'type': 'BootstrapProvider',
            'configFolder': 'bootstrap/kubeadm/config',
      },
      'control-plane-kubeadm': {
            'componentsFile': 'control-plane-components.yaml',
            'nextVersion': 'v0.3.0',
            'type': 'ControlPlaneProvider',
            'configFolder': 'controlplane/kubeadm/config',
      },
      'infrastructure-docker': {
          'componentsFile': 'infrastructure-components.yaml',
          'nextVersion': 'v0.3.0',
          'type': 'InfrastructureProvider',
          'configFolder': 'v0.3.0',
      },
}

docker_metadata_yaml = """\
apiVersion: clusterctl.cluster.x-k8s.io/v1alpha3
kind: Metadata
releaseSeries:
- major: 0
  minor: 2
  contract: v1alpha2
- major: 0
  minor: 3
  contract: v1alpha3
"""

def load_settings():
    global settings
    try:
        settings = json.load(open('clusterctl-settings.json'))
        #print('settings')
        #print('')
        #print(settings)
    except  Exception as e:
        raise Exception('failed to load clusterctl-settings.json: {}'.format(e))

def load_providers():
    provider_repos = settings.get('provider_repos', [])
    #print(provider_repos)
    for repo in provider_repos:
        file = repo + '/clusterctl-settings.json'
        print("Repo + File: ", file)
        try:
            provider_details = json.load(open(file))
            provider_name = provider_details['name']
            provider_config = provider_details['config']
            provider_config['repo'] = repo
            providers[provider_name] = provider_config
            print("provider_details: ", provider_details)
            print("provider_name: ", provider_name)
            print("provider_config: ", provider_config)
            print("provider config repo: ",provider_config['repo'])
            print("provider_name:", providers[provider_name])
            print("")
        except  Exception as e:
            raise Exception('failed to load clusterctl-settings.json from repo {}: {}'.format(repo, e))

def execCmd(args):
    try:
        out = subprocess.Popen(args,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)

        stdout, stderr = out.communicate()
        if stderr is not None:
            raise Exception('stderr contains: \n{}'.format(stderr))

        return stdout
    except  Exception as e:
        raise Exception('failed to run {}: {}'.format(args, e))

def get_home():
    return os.path.expanduser('~')

def write_local_override(provider, version, components_file, components_yaml):
    try:
        home = get_home()
        overrides_folder = os.path.join(home, '.cluster-api', 'overrides')
        #print("Overrides Folder: ", overrides_folder)
        provider_overrides_folder = os.path.join(overrides_folder, provider, version)
        #print("Provider Overrides Folder: ", provider_overrides_folder)
        try:
            os.makedirs(provider_overrides_folder)
        except OSError as e:
            if e.errno != errno.EEXIST:
                raise
        f = open(os.path.join(provider_overrides_folder, components_file), 'wb')
        f.write(components_yaml)
        f.close()
    except Exception as e:
        raise Exception('failed to write {} to {}: {}'.format(components_file, provider_overrides_folder, e))

def write_docker_metadata(version):
    try:
        home = get_home()
        docker_folder = os.path.join(home, '.cluster-api', 'overrides', 'infrastructure-docker', version)
        #print("metadata.yaml => ",docker_folder)

        f = open(os.path.join(docker_folder, "metadata.yaml"), 'w')
        f.write(docker_metadata_yaml)
        f.close()
    except Exception as e:
        raise Exception('failed to write {} to {}: {}'.format("metadata.yaml", metadata_folder, e))

def create_local_overrides():
    providerList = settings.get('providers', [])
    assert providerList is not None, 'invalid configuration: please define the list of providers to override'
    assert len(providerList)>0, 'invalid configuration: please define at least one provider to override'
    #print(providerList)

    for provider in providerList:
        p = providers.get(provider)
        assert p is not None, 'invalid configuration: please specify the configuration for the {} provider'.format(provider)

        repo = p.get('repo', '.')
        config_folder = p.get('configFolder', 'config')

        next_version = p.get('nextVersion')
        assert next_version is not None, 'invalid configuration for provider {}: please provide nextVersion value'.format(provider)

        name, type =splitNameAndType(provider)
        assert name is not None, 'invalid configuration for provider {}: please use a valid provider label'.format(provider)

        components_file = p.get('componentsFile')
        #print("Repository => ", repo)
        #print("Config Folder => ", config_folder)
        #print("Next Version => ", next_version)
        #print("Name => ", name)
        assert components_file is not None, 'invalid configuration for provider {}: please provide componentsFile value'.format(provider)
        components_yaml = execCmd(['kustomize', 'build', os.path.join(repo, config_folder)])
        #print("Components.yaml => ", os.path.join(repo, config_folder))

        write_local_override(provider, next_version, components_file, components_yaml)

        if provider == 'infrastructure-docker':
            #print("Docker Provider Detected")
            #print("")
            write_docker_metadata(next_version)

        yield name, type, next_version

def splitNameAndType(provider):
    if provider == 'cluster-api':
        return 'cluster-api', 'CoreProvider'
    if provider.startswith('bootstrap-'):
        return provider[len('bootstrap-'):], 'BootstrapProvider'
    if provider.startswith('control-plane-'):
        return provider[len('control-plane-'):], 'ControlPlaneProvider'
    if provider.startswith('infrastructure-'):
        return provider[len('infrastructure-'):], 'InfrastructureProvider'
    return None, None

def CoreProviderFlag():
    return '--core'

def BootstrapProviderFlag():
    return '--bootstrap'

def ControlPlaneProviderFlag():
    return '--control-plane'

def InfrastructureProviderFlag():
    return '--infrastructure'

def type_to_flag(type):
    switcher = {
        'CoreProvider': CoreProviderFlag,
        'BootstrapProvider': BootstrapProviderFlag,
        'ControlPlaneProvider': ControlPlaneProviderFlag,
        'InfrastructureProvider': InfrastructureProviderFlag
    }
    func = switcher.get(type, lambda: 'Invalid type')
    return func()

def print_instructions(overrides):
    providerList = settings.get('providers', [])
    print ('airshipctl local overrides generated from local repository for docker provider airshipctl/manifests/function/capd/v0.3.0'.format(', '.join(providerList)))
    print ('in order to use them, please run:')
    print
    cmd = 'airshipctl cluster init'
    for name, type, next_version in overrides:
        cmd += ' {} {}'.format(type_to_flag(type), name, next_version)
    #print (cmd)
    #print
    #if 'infrastructure-docker' in providerList:
        #print ('please check the documentation for additional steps required for using the docker provider')
        #print
    print('airshipctl cluster init --debug')


load_settings()

load_providers()

overrides = create_local_overrides()

print_instructions(overrides)
