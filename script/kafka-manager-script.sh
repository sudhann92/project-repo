#!/bin/bash

date_time=$(date +%d-%b-%y-%H-%M)
CONNECT_URL="http://localhost:8083"
KAFKA_BIN_PATH="/opt/kafka/bin"
TEMPLATE_PATH="/opt/kafka/custom-script/connector_template.json"
BOOTSTRAP_SERVER="localhost:9091"
GREEN='\033[0;32m'
NC='\033[0m'
items=( "kafka" "kafka-connect" "custom-kafka-file-connector" )


function Service_status_kafka_kafka_connect_custom_connector() {
        for service in ${items[@]}
        do
                _status=$(systemctl status "$service" | grep -iw "active" | cut -d ":" -f2)
                echo "-----------------------------------------"
                echo -e "$service service status = $_status"
                echo "-----------------------------------------"
        done
}


function Restart_kafka_service() {
        echo "Before Restarting the Kafka service Need to Stop the Kafka_Conncetor & Custom_File_connector services......."
        systemctl stop ${items[2]} && sleep 2
        systemctl stop ${items[1]} && sleep 2
        systemctl restart ${items[0]}
        kafka_status_1=$(systemctl status "${items[0]}" | grep -iw "active" | cut -d ":" -f2)
        sleep 4
        systemctl status ${items[0]} | grep -iw "running"
        out_put=$(echo $?)

        if [ "$out_put" == 0 ]
        then
            echo "-----------------------------------------"
            echo -e "Kafka service status = $kafka_status_1 RUNNING\n"
            echo "Starting the Kafka_connector & Custom_File_connector services......."
            systemctl start ${items[1]} && sleep 3
            systemctl start ${items[0]} && sleep 3
        else
                echo -e "\033[31m THERE IS SOME ISSUE IN KAFKA SERVICE KINDLY CHECK MANUALLY \033[0m\n"
        fi


}


function Restart_kafka_connect_service() {
        echo "Before restarting the Kafka_connect service Need to Stop the Custom_File_connector service......."
        systemctl stop ${items[2]} && sleep 2
        echo "Restarting the kafka_connect service......."
        systemctl stop ${items[1]} && ]sleep 2
        kafka_connect_status_1=$(systemctl status kafka-connect.service | grep -i "active" | cut -d ":" -f2)
        sleep 4
        systemctl status ${items[1]} | grep -iw "running"
        out_put=$(echo $?)
        if [ "$out_put" == 0 ]
        then
        echo "-----------------------------------------"
        echo -e "Kafka_connect service status = $kafka_connect_status_1 RUNNING\n"
        echo "Starting the Custom_File_connector services......."
        systemctl start ${items[2]} && sleep 2
        else
                echo -e "\033[31m THERE IS SOME ISSUE IN KAFKA_CONNECT SERVICE KINDLY CHECK MANUALLY \033[0m\n"
        fi

}


function Check_kafka_connect_API_Status() {
        echo "Checking API Status By displaying the version...."
        version=$(curl -s $CONNECT_URL/ |jq -r .version)
        if [ "$version" != "null" ] || [ ! -z "$version" ]
        then
        echo "-----------------------------------------"
        echo -e "\033[33m Kafka_Connect $version version........ \033[0m \n"
        else
        echo "-----------------------------------------"
        echo -e "\033[31m kafka_connect API not runnning. kindly restart the kafka service or check manually \033[0m\n"
        fi
}

function view_connectors() {
    echo "Fetching list of connectors..."
    curl -s "$CONNECT_URL/connectors" | jq
}

function check_connector_status() {
    view_connectors
    echo "----------------------------------------"
    echo "Based on above list of connection kindly select and Enter which connector do you want to check the status"
    echo "----------------------------------------"
    read -p "Enter connector name to check status: " cname
    curl -s "$CONNECT_URL/connectors/$cname/status" | jq
}


function check_connector_config() {
    view_connectors
    echo "----------------------------------------"
    echo "Based on above list of connection kindly select and Enter which connector do you want to check the config"
    echo "----------------------------------------"
    read -p "Enter connector name to check config details: " cname
    curl -s "$CONNECT_URL/connectors/$cname/config" | jq
}


function create_connector() {
    read -p "Enter unique connector name(Example enter the one DB table name): " cname
    read -p "Enter table name to capture: " tname

    if [ ! -f "$TEMPLATE_PATH" ]; then
        echo "Template file not found at $TEMPLATE_PATH"
        return
    fi

    # Create connector config JSON by replacing placeholders
    temp_file=$(mktemp)
    sed -e "s/{{CONNECTOR_NAME}}/$cname/g" -e "s/{{TABLE_NAME}}/$tname/g" -e "s/{{date_time}}/$date_time/g" "$TEMPLATE_PATH" > "$temp_file"

    echo "Creating connector..."
    curl -s -X POST -H "Content-Type: application/json" \
        --data "@$temp_file" "$CONNECT_URL/connectors" | jq

    rm -f "$temp_file"
    sleep 5
    echo "Please wait for 2 to 3 Minutes to create topic by kafka connector....\nIf more than 5 Min check the status of connector and restart the connector then check again....\nIf restart connector also not resolved means then finally restart the kafka connector service...."
}

function delete_connector() {
    view_connectors
    echo "----------------------------------------"
    echo "Based on above list of connectior kindly select and Enter which connector do you want to DELETE PERMENTALY"
    echo "----------------------------------------"
    read -p "Enter connector name to delete: " cname
    curl -s -X DELETE "$CONNECT_URL/connectors/$cname" | jq
    sleep 3
    echo "$cname Got deleted from the kafka connectors below are the available connectors in Kafka connect"
    view_connectors
}

function delete_topic() {
        read -p "Enter topic name(s) to delete (comma-separated for multiple): " tnames
        IFS=',' read -ra TOPIC_ARRAY <<< "$tnames"

        for topic in "${TOPIC_ARRAY[@]}"; do
           topic=$(echo "$topic" | xargs) # Trim whitespace
           if [ -n "$topic" ]; then
             echo "Deleting topic: $topic"
             $KAFKA_BIN_PATH/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --delete --topic "$topic"
           fi
        done
}


function check_topic_data() {
    read -p "Enter topic name to consume from: " tname
    echo "Press Ctrl+C to stop consuming."
    $KAFKA_BIN_PATH/kafka-console-consumer.sh --bootstrap-server $BOOTSTRAP_SERVER --topic "$tname" --from-beginning
}


function list_kafka_topic() {
        $KAFKA_BIN_PATH/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER --list
}


function restart_conenctors(){
        read -p "Enter connector name to restart: " cname
        curl -s -X POST  "$CONNECT_URL/connectors/$cname/restart" | jq
}


while true; do

    echo -e "${GREEN}===================================="
    echo -e "    Kafka Connector Manager"
    echo "===================================="
    echo -e "\n\t1. Check the status of Kafka,kafka-connect,Custom-file-connector service"
    echo -e "\n\t2. Restart the kafka service"
    echo -e "\n\t3. Restart the Kafka-Connect service"
    echo -e "\n\t4. kafka-connect API status"
    echo -e "\n\t5. View the External kafka Connectors"
    echo -e "\n\t6. Check Particular External Connector Status"
    echo -e "\n\t7. Check External Connector Configuration in Kafka API"
    echo -e "\n\t8. Create New MYSQL TABLE Debezium Connector"
    echo -e "\n\t9. Display the Topic Data (from beginning)"
    echo -e "\n\t10. List the Kafka Topics"
    echo -e "\n\t11. Restart the External Connector"
    echo -e "\n\t12. Delete an External Connector"
    echo -e "\n\t13. Delete a Topic"
    echo -e "\n\t14. Exit"${NC}

    echo -e "\n"
    read -p "Chooose an option: " choice
    echo -e "\n"

    case $choice in
        1) Service_status_kafka_kafka_connect_custom_connector ;;
        2) Restart_kafka_service ;;
        3) Restart_kafka_connect_service ;;
        4) Check_kafka_connect_API_Status ;;
        5) view_connectors ;;
        6) check_connector_status ;;
        7) check_connector_config ;;
        8) create_connector ;;
        9) check_topic_data ;;
        10) list_kafka_topic ;;
        11) restart_conenctors ;;
        12) delete_connector ;;
        13) delete_topic ;;
        14) echo "Goodbye!" ; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
