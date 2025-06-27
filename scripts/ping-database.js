const { Client } = require('pg');

async function pingDatabase() {
    // Create database client with connection details from environment variables
    const client = new Client({
        host: process.env.SUPABASE_DB_HOST,
        port: parseInt(process.env.SUPABASE_DB_PORT || '5432'),
        user: process.env.SUPABASE_DB_USER,
        password: process.env.SUPABASE_DB_PASSWORD,
        database: 'postgres',
        ssl: {
            rejectUnauthorized: false
        }
    });

    try {
        console.log('🔌 Connecting to Supabase database...');

        // Connect to the database
        await client.connect();
        console.log('✅ Connected to database successfully');

        // Execute a simple query to keep the database active
        const result = await client.query('SELECT NOW() as current_time, version() as db_version');

        console.log('📊 Database ping results:');
        console.log(`   Current time: ${result.rows[0].current_time}`);
        console.log(`   Database version: ${result.rows[0].db_version.split(' ')[0]}`);

        // Optional: You can also check if your n8n tables exist
        const tableCheck = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name LIKE '%n8n%' 
      LIMIT 5
    `);

        if (tableCheck.rows.length > 0) {
            console.log('🏷️  Found n8n tables:', tableCheck.rows.map(row => row.table_name).join(', '));
        }

        console.log('🎉 Database ping completed successfully!');

    } catch (error) {
        console.error('❌ Database ping failed:', error.message);

        // Provide helpful error information
        if (error.code === 'ENOTFOUND') {
            console.error('   Issue: Cannot resolve database host');
        } else if (error.code === 'ECONNREFUSED') {
            console.error('   Issue: Connection refused - database may be paused');
        } else if (error.message.includes('password authentication failed')) {
            console.error('   Issue: Invalid credentials');
        }

        process.exit(1);
    } finally {
        // Always close the connection
        try {
            await client.end();
            console.log('🔌 Database connection closed');
        } catch (closeError) {
            console.warn('⚠️  Warning: Could not close database connection properly');
        }
    }
}

// Execute the ping function
pingDatabase();
