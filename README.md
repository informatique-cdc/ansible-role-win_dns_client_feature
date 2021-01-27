# win_dns_client_feature - Enable or disable certain DNS client features

## Synopsis

* This Ansible module allows to enable or disable some feature of the DNS client of all the network adapters.

## Parameters

| Parameter     | Choices/<font color="blue">Defaults</font> | Comments |
| ------------- | ---------|--------- |
|__enable_multi_cast__<br><font color="purple">boolean</font></font> | __Choices__: <ul><li>no</li><li>yes</li></ul> | Specifies whether the Multicast Name Resolution (LLMNR) is enabled.<br>If this value is set to `true`, the host can perform name resolution for hosts on the same local link without the requirement of a DNS server. |

## Examples

```yaml
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

```

## Authors

* Stéphane Bilqué (@sbilque) Informatique CDC

## License

This project is licensed under the Apache 2.0 License.

See [LICENSE](LICENSE) to see the full text.
