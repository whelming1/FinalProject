package ticket.utils.com.siot.IamportRestClient.response.naver;

import com.google.gson.annotations.SerializedName;

public class NaverProductOrder {

	@SerializedName("product_order_id")
	String product_order_id;
	
	@SerializedName("product_order_status")
	String product_order_status;
	
	@SerializedName("claim_type")
	String claim_type;
	
	@SerializedName("claim_status")
	String claim_status;
	
	@SerializedName("product_id")
	String product_id;
	
	@SerializedName("product_name")
	String product_name;
	
	@SerializedName("product_option_id")
	String product_option_id;
	
	@SerializedName("product_option_name")
	String product_option_name;
	
	@SerializedName("quantity")
	int quantity;
	
	@SerializedName("orderer")
	NaverOrderer orderer;
	
	@SerializedName("shipping_address")
	NaverShippingAddress shipping_address;

	public String getProductOrderId() {
		return product_order_id;
	}

	public String getProductOrderStatus() {
		return product_order_status;
	}

	public String getClaimType() {
		return claim_type;
	}

	public String getClaimStatus() {
		return claim_status;
	}

	public String getProductId() {
		return product_id;
	}

	public String getProductName() {
		return product_name;
	}

	public String getProductOptionId() {
		return product_option_id;
	}

	public String getProductOptionName() {
		return product_option_name;
	}

	public int getQuantity() {
		return quantity;
	}

	public NaverOrderer getOrderer() {
		return orderer;
	}

	public NaverShippingAddress getShippingAddress() {
		return shipping_address;
	}
	
}
