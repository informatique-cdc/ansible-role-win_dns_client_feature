#!/usr/bin/python
# -*- coding: utf-8 -*-

# This is a role documentation stub.

# Copyright 2020 Informatique CDC. All rights reserved.
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
# limitations under the License

from __future__ import absolute_import, division, print_function
__metaclass__ = type


ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_dns_client_feature
short_description: Enable or disable certain DNS client features
author:
    - Stéphane Bilqué (@sbilque) Informatique CDC
description:
    - This Ansible module allows to enable or disable some feature of the DNS client of all the network adapters.
options:
    enable_multi_cast:
        description:
            - Specifies whether the Multicast Name Resolution (LLMNR) is enabled.
            - If this value is set to C(true), the host can perform name resolution for hosts on the same local link without the requirement of a DNS server.
        type: bool
        choices: [ true, false ]
'''


EXAMPLES = r'''
---
- name: test the win_dns_client_feature module
  hosts: all
  gather_facts: false

  roles:
    - win_dns_client_feature

  tasks:
    - name: Turn off Multicast Name Resolution
      win_dns_client_feature:
        enable_multi_cast: false

'''
