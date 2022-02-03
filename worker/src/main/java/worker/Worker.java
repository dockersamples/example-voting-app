package worker;

import redis.clients.jedis.Jedis;

import java.security.InvalidParameterException;
import java.sql.*;
import org.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Worker {

  private static final Logger logger = LoggerFactory.getLogger(Worker.class);

  private PreparedStatement SELECT_STATEMENT = null;
  private PreparedStatement INSERT_STATEMENT = null;
  private PreparedStatement UPDATE_STATEMENT = null;

  private Jedis redis = null;
  private Connection dbConn = null;


  public static void main(String[] args) throws SQLException, InterruptedException {
    Worker w = new Worker();
    logger.info("Watching vote queue");
    while(true) {
      w.work();
    }
  }

  public Worker() throws SQLException {
    String redisHost = getEnv("REDIS_HOST");    
    Integer redisPort = Integer.parseInt(getEnv("REDIS_PORT"));
    Integer redisDb = Integer.parseInt(getEnv("REDIS_DB"));
    String postgresUser = getEnv("POSTGRES_USER");
    String postgresPassword = getEnv("POSTGRES_PASSWORD");
    String postgresHost = getEnv("POSTGRES_HOST");
    String postgresPort = getEnv("POSTGRES_PORT");
    String postgresDatabase = getEnv("POSTGRES_DB");

    redis = this.connectToRedis("redis://" + redisHost + ":" + redisPort + "/" + redisDb);
    dbConn = this.connectToDB("jdbc:postgresql://" + postgresHost + ':' + postgresPort + '/' + postgresDatabase, postgresUser, postgresPassword);

    SELECT_STATEMENT = dbConn.prepareStatement("SELECT id FROM votes WHERE (id = ?::varchar)");
    INSERT_STATEMENT = dbConn.prepareStatement("INSERT INTO votes (id, vote) VALUES (?,?)");
    UPDATE_STATEMENT = dbConn.prepareStatement("UPDATE votes SET vote = ? WHERE id = ?");
  }

  private void work() throws SQLException {
    String voteJSON = redis.blpop(0, "votes").get(1);
    JSONObject voteData = new JSONObject(voteJSON);
    String voterID = voteData.getString("voter_id");
    String vote = voteData.getString("vote");

    logger.debug("Processing vote for {} by {}", vote, voterID);
    updateVote(dbConn, voterID, vote);
  }

  private String getEnv(String varEnv) {
    String value = System.getenv(varEnv);
    if(value == null) {
      logger.error("cannot found var env {}", varEnv);
      throw new InvalidParameterException("cannot found var env " + varEnv);
    }
    else {
      return  value;
    }
  }

  private void updateVote(Connection dbConn, String voterID, String vote) throws SQLException {

    logger.debug("SELECT id {}", voterID);
    SELECT_STATEMENT.setString(1, voterID);
    ResultSet rs = SELECT_STATEMENT.executeQuery();

    if(rs.next()){
      logger.debug("UPDATE votedID {} with vote {}", voterID, vote);
      UPDATE_STATEMENT.setString(1, vote);
      UPDATE_STATEMENT.setString(2, voterID);
      UPDATE_STATEMENT.executeUpdate();
    } else {
      logger.debug("INSERT votedID {} with vote {}", voterID, vote);
      INSERT_STATEMENT.setString(1, voterID);
      INSERT_STATEMENT.setString(2, vote);
      INSERT_STATEMENT.executeUpdate();
  }
}

  private Jedis connectToRedis(String url) {
    logger.info("connection to redis url {}", url);
    Jedis conn = new Jedis(url);
    conn.keys("*");
    logger.info("connected to redis url {}", url);
    return conn;
  }

  private Connection connectToDB(String url, String user, String password) throws SQLException {
        logger.info("connection to db url {}, user {}", url, user);
        Connection connection =  DriverManager.getConnection(url, user, password);
        logger.info("connected to db url {}, user {}", url, user);
        return connection;
    }
}
