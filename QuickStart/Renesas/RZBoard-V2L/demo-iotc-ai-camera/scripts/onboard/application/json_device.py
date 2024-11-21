'''Device model using json credentials and supporting script commands'''
import os
from typing import Union # to use Union[Enum, None] type hint
from enum import Enum
import subprocess
import struct
from model.device_model import ConnectedDevice
from model.enums import Enums as E
import json
import psutil  # Add this for system monitoring

def log_system_usage():
    """Logs CPU and memory usage and returns the data."""
    cpu_usage = psutil.cpu_percent(interval=1)
    mem = psutil.virtual_memory()
    mem_usage = mem.percent

    # Log or return the values as needed
    return {
        'cpu_usage': cpu_usage,
        'mem_usage': mem_usage
    }

class DynAttr:

    name = None
    path = None
    read_type = None

    def __init__(self, name, path,read_type):
        self.name = name
        self.path = path
        self.read_type = read_type

    def update_value(self):
        val = None
        try:
            if self.read_type == E.ReadTypes.ascii:
                with open(self.path, "r", encoding="utf-8") as f:
                    val = f.read()

            if self.read_type == E.ReadTypes.binary:
                with open(self.path, "rb") as f:
                    val = f.read()

        except FileNotFoundError:
            print("File not found at", self.path)
        return val

    def get_value(self,to_type):
        val = self.update_value()
        val = self.convert(val,to_type)
        return val

    def convert(self,val,to_type):
        if self.read_type == E.ReadTypes.binary:
            if to_type in [E.SendDataTypes.INT, E.SendDataTypes.LONG]:
                return int.from_bytes(val, 'big')

            elif to_type in [E.SendDataTypes.FLOAT]:
                return (struct.unpack('f', val)[0])

            elif to_type in [E.SendDataTypes.STRING]:
                return val.decode("utf-8")

            elif to_type in [E.SendDataTypes.Boolean]:
                return struct.unpack('?', val)[0]

            elif to_type in [E.SendDataTypes.BIT]:
                if struct.unpack('?', val)[0]:
                    return 1
                return 0

        if self.read_type == E.ReadTypes.ascii:
            try:
                if to_type in [E.SendDataTypes.INT, E.SendDataTypes.LONG]:
                    return int(float(val))

                elif to_type in [E.SendDataTypes.FLOAT]:
                    return float(val)

                elif to_type in [E.SendDataTypes.STRING]:
                    return str(val)

                elif to_type in [E.SendDataTypes.BIT]:
                    if self.convert(val, E.SendDataTypes.INT) != 0:
                        return 1
                    return 0

                elif to_type in [E.SendDataTypes.Boolean]:
                    if type(val) == bool:
                        return val

                    elif type(val) == int:
                        return val != 0

                    elif type(val) == str:
                        if val in ["False", "false", "0", ""]:
                            return False
                        return True

            except Exception as exception:
                print(exception)
        return None


class JsonDevice(ConnectedDevice):
    attributes: DynAttr = []
    # attributes is a list of attributes brought in from json
    # the DynAttr class holds the metadata only, E.g. where the value is saved as a file - the attribute itself is set on the class
    # in the override of the super get_state()

    parsed_json: dict = {}
    SCRIPTS_PATH:str = ""
    scripts: list = []

    class DeviceCommands(Enum):
        EXEC = "exec"

        @classmethod
        def get(cls, command:str) -> Union[Enum, None]:
            '''Validates full command string against accepted enumerated commands'''
            if command in [dc.value for dc in cls]:
                    return cls(command)
            return None

    def __init__(self, conf_file):

        j: json = None
        with open(conf_file, "r", encoding="utf-8") as file:
            f_contents = file.read()
            j = json.loads(f_contents)

        test = 'duid'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'cpid'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'env'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'iotc_server_cert'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'sdk_id'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'discovery_url'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'connection_type'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'auth'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'auth_type'
        if test not in j['auth']:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'params'
        if test not in j['auth']:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'device'
        if test not in j:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'commands_list_path'
        if test not in j['device']:
            raise ValueError(f"ERROR - {test} not in json")

        test = 'attributes'
        if test not in j['device']:
            raise ValueError(f"ERROR - {test} not in json")

        auth_type = j['auth']['auth_type']
        discovery_url = j['discovery_url']
        sdk_id = j['sdk_id']
        iotc_server_cert = j['iotc_server_cert']
        env = j['env']
        cpid = j['cpid']
        duid = j['duid']
        commands_list_path = j['device']['commands_list_path']

        connection_type = j['connection_type']
        pf = ""
        if connection_type == "IOTC_CT_AZURE":
            pf = "az"
        if connection_type == "IOTC_CT_AWS":
            pf = "aws"

        attributes = j['device']['attributes']
        for attr in attributes:
            m_att = DynAttr(attr["name"],attr["private_data"],attr["private_data_type"])
            self.attributes.append(m_att)

        sdk_options = {}
        sdk_options.update({'cpid': cpid})

        # sdk_id causes problems for now
        # sdk_options.update({'sId': sdk_id})

        sdk_options.update({'env': env})
        sdk_options.update({'pf': pf})
        sdk_options.update({'discoveryUrl' : discovery_url})

        if auth_type == "IOTC_AT_X509":
            test = 'client_key'
            if test not in j['auth']['params']:
                raise ValueError(f"ERROR - {test} not in json")

            test = 'client_cert'
            if test not in j['auth']['params']:
                raise ValueError(f"ERROR - {test} not in json")

            client_key = j['auth']['params']['client_key']
            client_cert = j['auth']['params']['client_cert']

            certificate = {
                "SSLKeyPath"  : client_key,
                "SSLCertPath" : client_cert,
                "SSLCaPath"   : iotc_server_cert,
            }
            sdk_options.update({"certificate" : certificate})

        super().__init__(
            company_id=cpid,
            unique_id=duid,
            environment=env,
            sdk_id=sdk_id,
            sdk_options=sdk_options
        )

        self.SCRIPTS_PATH = commands_list_path
        self.get_all_scripts()


    def get_state(self):
        '''Do not override'''
        data_obj = {}
        data_obj.update(self.get_attributes_state())
        data_obj.update(self.get_local_state())
        return data_obj

    def get_attributes_state(self) -> dict:
        '''Gets all attributes specified from the JSON file'''
        data_obj = {}
        attribute: DynAttr
        for attribute in self.attributes:
            for metadata in self.attribute_metadata:
                if attribute.name == metadata[E.MetadataKeys.name]:
                    data_obj[attribute.name] = attribute.get_value(metadata[E.MetadataKeys.data_type])
                    break

        return data_obj

    def get_local_state(self) -> dict:
        '''Overrideable - return dictionary of local data to send to the cloud'''
        local_data = {}

        # Collect system stats
        system_stats = self.get_system_stats()
        local_data.update(system_stats)

        return local_data

    def get_system_stats(self):
        '''Function to get system resource statistics (CPU, memory)'''
        cpu_usage = psutil.cpu_percent(interval=1)
        memory_info = psutil.virtual_memory()
        mem_usage = memory_info.percent
        return {
            "cpu_usage": cpu_usage,
            "mem_usage": mem_usage
        }

    def ota_cb(self,msg):
        from model.ota_handler import OtaHandler
        OtaHandler(self,msg)

    def get_all_scripts(self):
        if not self.SCRIPTS_PATH.endswith('/'):
            self.SCRIPTS_PATH += '/'
        self.scripts: list = [f for f in os.listdir(self.SCRIPTS_PATH) if os.path.isfile(os.path.join(self.SCRIPTS_PATH, f))]

    def device_cb(self, msg):
        command: list = E.get_value(msg, E.Keys.device_command).split(' ')

        if command[0] in self.scripts:
            command[0] = self.SCRIPTS_PATH + command[0]

            # Log system usage before execution
            log_system_usage()

            try:
                # Non-blocking command execution
                process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout, stderr = process.communicate(timeout=15)

                if process.returncode != 0:
                    raise Exception(f"Command failed with error: {stderr.decode('utf-8')}")

                process_output = stdout.decode('utf-8')
                print(f"Command executed successfully: {process_output}")

                # Acknowledge the successful execution to IoTConnect
                self.send_ack(msg, E.Values.AckStat.SUCCESS, process_output)

            except subprocess.TimeoutExpired:
                process.kill()
                print(f"Command timed out: {command}")
                self.send_ack(msg, E.Values.AckStat.FAIL, "Command timed out.")

            except Exception as e:
                print(f"Error executing command: {str(e)}")
                self.send_ack(msg, E.Values.AckStat.FAIL, str(e))

            # Log system usage after execution
            log_system_usage()

            return

        self.send_ack(msg, E.Values.AckStat.FAIL, f"Command {command[0]} does not exist")

