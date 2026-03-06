package util;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import model.Booking;
import model.Guest;
import model.Room;

import java.io.InputStream;
import java.text.DecimalFormat;
import java.util.Map;
import java.util.Properties;

public class EmailService {

    private static final Properties emailConfig = new Properties();
    private static boolean configured = false;

    static {
        try (InputStream is = EmailService.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                emailConfig.load(is);
                configured = true;
            } else {
                System.err.println("EmailService: email.properties not found on classpath.");
            }
        } catch (Exception e) {
            System.err.println("EmailService: Failed to load email.properties - " + e.getMessage());
        }
    }

    // ---------------------------------------------------------------
    // Send booking confirmation email to the guest
    // ---------------------------------------------------------------
    public static void sendBookingConfirmation(Guest guest, Booking booking, Room room) {
        if (!configured) {
            System.err.println("EmailService: Not configured – skipping booking confirmation email.");
            return;
        }

        String to = guest.getEmail();
        String subject = "Booking Confirmation – Ocean View Resort (Booking #" + booking.getId() + ")";

        String roomNumber = (room != null) ? room.getRoomNumber() : "To be assigned";
        String roomType = capitalize(booking.getRoomType());

        String body = buildBookingConfirmationBody(guest, booking, roomNumber, roomType);

        new Thread(() -> {
            try {
                send(to, subject, body);
                System.out.println("EmailService: Booking confirmation sent to " + to);
            } catch (Exception e) {
                System.err.println("EmailService: Failed to send booking confirmation to " + to + " - " + e.getMessage());
            }
        }, "email-booking-" + booking.getId()).start();
    }

    // ---------------------------------------------------------------
    // Send checkout bill email to the guest
    // ---------------------------------------------------------------
    public static void sendCheckoutBill(Guest guest, Booking booking, Room room, Map<String, Object> billDetails) {
        if (!configured) {
            System.err.println("EmailService: Not configured – skipping checkout bill email.");
            return;
        }

        String to = guest.getEmail();
        String subject = "Your Bill – Ocean View Resort (Booking #" + booking.getId() + ")";

        String body = buildBillBody(guest, booking, room, billDetails);

        new Thread(() -> {
            try {
                send(to, subject, body);
                System.out.println("EmailService: Checkout bill sent to " + to);
            } catch (Exception e) {
                System.err.println("EmailService: Failed to send checkout bill to " + to + " - " + e.getMessage());
            }
        }, "email-bill-" + booking.getId()).start();
    }

    // ---------------------------------------------------------------
    // Core send method
    // ---------------------------------------------------------------
    private static void send(String to, String subject, String htmlBody) throws MessagingException, java.io.UnsupportedEncodingException {
        String host     = emailConfig.getProperty("mail.smtp.host", "smtp.gmail.com");
        String port     = emailConfig.getProperty("mail.smtp.port", "587");
        String from     = emailConfig.getProperty("mail.from");
        String password = emailConfig.getProperty("mail.password");
        String fromName = emailConfig.getProperty("mail.from.name", "Ocean View Resort");

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", emailConfig.getProperty("mail.smtp.auth", "true"));
        props.put("mail.smtp.starttls.enable", emailConfig.getProperty("mail.smtp.starttls.enable", "true"));

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(from, fromName));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        message.setContent(htmlBody, "text/html; charset=utf-8");

        Transport.send(message);
    }

    // ---------------------------------------------------------------
    // Email body builders
    // ---------------------------------------------------------------
    private static String buildBookingConfirmationBody(Guest guest, Booking booking,
                                                        String roomNumber, String roomType) {
        return "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;color:#333;max-width:600px;margin:auto;'>"
            + "<div style='background:#003366;padding:20px;text-align:center;'>"
            + "<h1 style='color:#fff;margin:0;'>Ocean View Resort</h1>"
            + "<p style='color:#cce0ff;margin:4px 0 0;'>Booking Confirmation</p>"
            + "</div>"
            + "<div style='padding:30px;'>"
            + "<p>Dear <strong>" + escHtml(guest.getFirstName() + " " + guest.getLastName()) + "</strong>,</p>"
            + "<p>Thank you for choosing <strong>Ocean View Resort</strong>! Your reservation has been confirmed.</p>"
            + "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
            + tableRow("Booking ID",       "#" + booking.getId())
            + tableRow("Room Type",        roomType)
            + tableRow("Room Number",      roomNumber)
            + tableRow("Number of Guests", String.valueOf(booking.getNumGuests()))
            + tableRow("Check-In Date",    booking.getCheckIn().toString())
            + tableRow("Check-Out Date",   booking.getCheckOut().toString())
            + tableRow("Duration",         booking.getNumberOfNights() + " night(s)")
            + (isNotBlank(booking.getSpecialRequests())
                    ? tableRow("Special Requests", escHtml(booking.getSpecialRequests())) : "")
            + "</table>"
            + "<p style='background:#e8f4e8;border-left:4px solid #4caf50;padding:12px;'>"
            + "Please present this confirmation at the front desk upon arrival.</p>"
            + "<p>If you have any questions, please contact us at <a href='mailto:"
            + escHtml(emailConfig.getProperty("mail.from", "")) + "'>"
            + escHtml(emailConfig.getProperty("mail.from", "")) + "</a>.</p>"
            + "<p>We look forward to welcoming you!</p>"
            + "</div>"
            + footer()
            + "</body></html>";
    }

    private static String buildBillBody(Guest guest, Booking booking, Room room,
                                         Map<String, Object> billDetails) {
        DecimalFormat df = new DecimalFormat("#,##0.00");

        long nights       = (long)    billDetails.getOrDefault("nights", 0L);
        double roomRate   = (double)  billDetails.getOrDefault("roomRate", 0.0);
        double subtotal   = (double)  billDetails.getOrDefault("subtotal", 0.0);
        double service    = (double)  billDetails.getOrDefault("serviceCharge", 0.0);
        double tax        = (double)  billDetails.getOrDefault("tax", 0.0);
        double total      = (double)  billDetails.getOrDefault("total", 0.0);
        String roomNumber = (room != null) ? room.getRoomNumber() : "N/A";
        String roomType   = capitalize(booking.getRoomType());

        return "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;color:#333;max-width:600px;margin:auto;'>"
            + "<div style='background:#003366;padding:20px;text-align:center;'>"
            + "<h1 style='color:#fff;margin:0;'>Ocean View Resort</h1>"
            + "<p style='color:#cce0ff;margin:4px 0 0;'>Checkout Invoice</p>"
            + "</div>"
            + "<div style='padding:30px;'>"
            + "<p>Dear <strong>" + escHtml(guest.getFirstName() + " " + guest.getLastName()) + "</strong>,</p>"
            + "<p>Thank you for staying with us. Below is your final invoice.</p>"
            + "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
            + tableRow("Booking ID",    "#" + booking.getId())
            + tableRow("Room Type",     roomType)
            + tableRow("Room Number",   roomNumber)
            + tableRow("Check-In",      booking.getCheckIn().toString())
            + tableRow("Check-Out",     booking.getCheckOut().toString())
            + tableRow("Nights",        String.valueOf(nights))
            + "</table>"
            + "<h3 style='border-bottom:2px solid #003366;padding-bottom:6px;'>Charges</h3>"
            + "<table style='width:100%;border-collapse:collapse;margin:10px 0;'>"
            + chargeRow("Room Rate per Night", "LKR " + df.format(roomRate))
            + chargeRow("Subtotal (" + nights + " night(s))", "LKR " + df.format(subtotal))
            + chargeRow("Service Charge (10%)", "LKR " + df.format(service))
            + chargeRow("Tax (12%)", "LKR " + df.format(tax))
            + "<tr style='background:#003366;color:#fff;font-weight:bold;font-size:16px;'>"
            + "<td style='padding:12px;'>Total Amount</td>"
            + "<td style='padding:12px;text-align:right;'>LKR " + df.format(total) + "</td></tr>"
            + "</table>"
            + "<p style='background:#fff3cd;border-left:4px solid #ffc107;padding:12px;'>"
            + "This email serves as your receipt. Please keep it for your records.</p>"
            + "<p>We hope you enjoyed your stay and look forward to seeing you again!</p>"
            + "</div>"
            + footer()
            + "</body></html>";
    }

    // ---------------------------------------------------------------
    // HTML helpers
    // ---------------------------------------------------------------
    private static String tableRow(String label, String value) {
        return "<tr style='border-bottom:1px solid #ddd;'>"
             + "<td style='padding:10px;font-weight:bold;width:45%;'>" + label + "</td>"
             + "<td style='padding:10px;'>" + escHtml(value) + "</td></tr>";
    }

    private static String chargeRow(String label, String value) {
        return "<tr style='border-bottom:1px solid #eee;'>"
             + "<td style='padding:8px;'>" + escHtml(label) + "</td>"
             + "<td style='padding:8px;text-align:right;'>" + escHtml(value) + "</td></tr>";
    }

    private static String footer() {
        return "<div style='background:#f5f5f5;padding:15px;text-align:center;font-size:12px;color:#666;'>"
             + "<p style='margin:0;'>&copy; Ocean View Resort. All rights reserved.</p>"
             + "</div>";
    }

    private static String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private static String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1).toLowerCase();
    }

    private static boolean isNotBlank(String s) {
        return s != null && !s.trim().isEmpty();
    }
}
