require 'pg'

module DTTForms
  # If we end up needing multiple types of connections, this should become abstract.
  # For now, it's both the abstract and the PGConnection. Its responsibility is to
  # insulate the dttform from having to know anything about the backend
  class Connection
    attr_reader :conn

    def initialize(opts={}, connection_type=PG::Connection)
      opts = {
        dbname: "",
        user: "",
        password: "",
        host: "localhost",
      }.merge(opts)

      @conn = connection_type.new(opts)
    end

    # return a spec document or raise an IndexError if one wasn't found
    def get_spec(specid)
      results = conn.exec_params("SELECT * FROM specs WHERE specid=$1", [specid])

      # PGResult fires an indexerror; make sure to raise instead of return nil
      results[0]
    end
  end
end
