FROM dcm4che/dcm4chee-arc-psql:5.33.1

# Copy the EAR file (this is the base deployment)
COPY dcm4chee-arc-ear/target/dcm4chee-arc-ear-*.ear /opt/wildfly/standalone/deployments/

# Override the UI WAR with your local version (new logo), renamed to trigger fresh deployment
COPY dcm4chee-arc-ui2/target/dcm4chee-arc-ui2-5.33.1.war /opt/wildfly/standalone/deployments/

# Optional: Copy docker-compose.yml (for testing/debugging purposes)
COPY docker-compose.yml /opt/wildfly/standalone/deployments/
RUN ls -al /opt/wildfly/standalone/deployments/
