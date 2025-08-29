-- Create a simple public test function
CREATE OR REPLACE FUNCTION get_current_timestamp()
RETURNS timestamp
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT now();
$$;

-- Grant execute permission to anon role
GRANT EXECUTE ON FUNCTION get_current_timestamp() TO anon;
GRANT EXECUTE ON FUNCTION get_current_timestamp() TO authenticated;
