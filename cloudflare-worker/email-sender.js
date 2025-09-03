/**
 * Cloudflare Worker for sending emails via Cloudflare Email API
 * This worker receives email requests from your Phoenix app and sends them using Cloudflare's Email API
 */

export default {
  async fetch(request, env) {
    // Only allow POST requests
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    // Verify API key for security
    const apiKey = request.headers.get('X-API-Key');
    if (apiKey !== env.PHOENIX_API_KEY) {
      return new Response('Unauthorized', { status: 401 });
    }

    try {
      const emailData = await request.json();
      
      // Validate required fields
      if (!emailData.to || !emailData.subject || !emailData.content) {
        return new Response('Missing required fields: to, subject, content', { 
          status: 400 
        });
      }

      // Send email using Cloudflare Email API
      const emailResult = await sendEmail(emailData, env);
      
      return new Response(JSON.stringify(emailResult), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });

    } catch (error) {
      console.error('Email sending error:', error);
      return new Response(JSON.stringify({ 
        error: 'Failed to send email',
        details: error.message 
      }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' }
      });
    }
  }
};

/**
 * Send email using Cloudflare's Email API
 */
async function sendEmail(emailData, env) {
  const { to, from, subject, content, reply_to } = emailData;

  // Prepare email message for Cloudflare Email API
  const message = {
    personalizations: [
      {
        to: Array.isArray(to) ? to.map(formatAddress) : [formatAddress(to)],
        subject: subject
      }
    ],
    from: formatAddress(from || { 
      email: `noreply@pondi.app`, 
      name: 'Inventory Tracker' 
    }),
    content: [
      {
        type: 'text/plain',
        value: content.text || content
      }
    ]
  };

  // Add HTML content if provided
  if (content.html) {
    message.content.push({
      type: 'text/html',
      value: content.html
    });
  }

  // Add reply-to if provided
  if (reply_to) {
    message.reply_to = formatAddress(reply_to);
  }

  // Use correct Cloudflare Email API endpoint
  const response = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${env.CLOUDFLARE_ACCOUNT_ID}/send/email`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${env.CLOUDFLARE_API_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(message)
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Cloudflare API error: ${response.status} - ${errorText}`);
  }

  const result = await response.json();
  
  return {
    success: true,
    message_id: result.result?.id || 'unknown',
    cloudflare_response: result
  };
}

/**
 * Format email address for API
 */
function formatAddress(address) {
  if (typeof address === 'string') {
    return { email: address };
  }
  
  if (address.email) {
    return {
      email: address.email,
      name: address.name || undefined
    };
  }
  
  return { email: address };
}

/**
 * CORS handling for preflight requests
 */
function handleCORS() {
  return new Response(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, X-API-Key',
      'Access-Control-Max-Age': '86400',
    }
  });
}