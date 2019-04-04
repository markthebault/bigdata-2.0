import sys
import json
import yaml



json_in = ""
for line in sys.stdin:
    json_in = json_in + line


role_arn = sys.argv[1]
config_map = json.loads(json_in)



add_role_str= "- rolearn: "+role_arn+"\n"
add_role_str +=" username: lambda\n"
# add_role_str +=" username: admin\n"
# add_role_str +=" groups:\n"
# add_role_str +=" - system:masters\n"

config_map['data']['mapRoles'] = config_map['data']['mapRoles'] + add_role_str

print(json.dumps(config_map))
